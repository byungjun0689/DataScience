package com.mycompany.app;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaDoubleRDD;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.mllib.recommendation.ALS;
import org.apache.spark.mllib.recommendation.MatrixFactorizationModel;
import org.apache.spark.mllib.recommendation.Rating;
import scala.Tuple2;

public class JavaRecommendationExample {
  public static void main(String[] args) {
    // 1. JavaSparkContext의 생성
    SparkConf conf = new SparkConf().setAppName("Java Collaborative Filtering Example").setMaster("local");
    JavaSparkContext jsc = new JavaSparkContext(conf);

    // 2. 샘플 데이터의 로딩 및 파싱
    String path = System.getProperty("user.home") + "/startup_in_action/examples/data/sample_movielens_ratings.txt";
    JavaRDD<String> data = jsc.textFile(path);
    JavaRDD<Rating> ratings = data.map(
      new Function<String, Rating>() {
        public Rating call(String s) {
          String[] sarray = s.split("::");
          return new Rating(Integer.parseInt(sarray[0]), Integer.parseInt(sarray[1]),
              Double.parseDouble(sarray[2]));
        }
      }
    );

    // 3. ALS 알고리즘을 이용한 예측 모델 생성
    int rank = 10;
    int numIterations = 10;
    MatrixFactorizationModel model = ALS.train(JavaRDD.toRDD(ratings), rank, numIterations, 0.01);

    // 4. 예측 모델의 검증
    //   4.1. userProducts RDD 생성
    JavaRDD<Tuple2<Object, Object>> userProducts = ratings.map(
      new Function<Rating, Tuple2<Object, Object>>() {
        public Tuple2<Object, Object> call(Rating r) {
          return new Tuple2<Object, Object>(r.user(), r.product());
        }
      }
    );
    //   4.2. 모델을 이용한 rating 결과 예측
    JavaPairRDD<Tuple2<Integer, Integer>, Double> predictions = JavaPairRDD.fromJavaRDD(
      model.predict(JavaRDD.toRDD(userProducts)).toJavaRDD().map(
        new Function<Rating, Tuple2<Tuple2<Integer, Integer>, Double>>() {
          public Tuple2<Tuple2<Integer, Integer>, Double> call(Rating r){
            return new Tuple2<Tuple2<Integer, Integer>, Double>(new Tuple2<Integer, Integer>(r.user(), r.product()), r.rating());
          }
        }
      ));
    //   4.3. 실제 관측된 rating 값과, 예측된(predicted) rating 값을 이용하여 RDD 생성
    JavaRDD<Tuple2<Double, Double>> ratesAndPreds =
      JavaPairRDD.fromJavaRDD(ratings.map(
        new Function<Rating, Tuple2<Tuple2<Integer, Integer>, Double>>() {
          public Tuple2<Tuple2<Integer, Integer>, Double> call(Rating r){
            return new Tuple2<Tuple2<Integer, Integer>, Double>(new Tuple2<Integer, Integer>(r.user(), r.product()), r.rating());
          }
        }
      )).join(predictions).values();
    //   4.4. 관측된 값과 예측된 값의 차이를 이용하여 MSE 값 계산
    double MSE = JavaDoubleRDD.fromRDD(ratesAndPreds.map(
      new Function<Tuple2<Double, Double>, Object>() {
        public Object call(Tuple2<Double, Double> pair) {
          Double err = pair._1() - pair._2();
          return err * err;
        }
      }
    ).rdd()).mean();
    System.out.println("Mean Squared Error = " + MSE);

    // 5. 모든 사용자에 대하여 상위 5개의 추천 결과를 출력
    JavaRDD<Tuple2<Object, Rating[]>> userRecs = model.recommendProductsForUsers(5).toJavaRDD();
    for(Tuple2<Object, Rating[]> rec : userRecs.collect()){
      System.out.println("# User ID : " + rec._1());
      for(Rating rating: rec._2()){
        System.out.println("# Movie ID : " + rating.product());
      }
    }

    jsc.stop();
  }
}
