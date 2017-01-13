$(function(){
  var converter = new showdown.Converter();

  var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
          return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
  };

  var loadNoteBook = function(json){
    for(var i in json.cells){
      var cell = json.cells[i];
      var div = $('<div class="cell"></div>');
      var html;

      if( cell.cell_type == 'markdown' ){
        html = converter.makeHtml(cell.source.join(''));
      }
      else {
        html = ''
        code = cell.source.join('')
        if( !code.match(/^#!hide/) ){ // 코드 숨김
          html = '<pre><code class="language-R">' + code + '</code></pre>';
        }
        for(var j in cell.outputs){
          output = cell.outputs[j];
          if('data' in output){
            if(code[0] == '?'){  // 도움말
              data = output['data']['text/html'].join('')
              html += '<div class="help">' + data + '</div>';
            }
            else if('image/png' in output['data']){ // plot
              html += '<img src="data:image/png;base64,' + output['data']['image/png'] + '">'
            }
            else {
              // data = output['data']['text/plain'].slice(0, 10).join('')
              data = output['data']['text/plain'].join('')
              html += '<pre class="output">' + data + '</pre>';
            }
          }
          else if('evalue' in output){
            html += '<pre class="error">' + output.evalue + '</pre>';
          }
        }
      }
      div.html(html);
      div.attr('data-cell-type', cell.cell_type);
      $.each(div.find('pre'), function(){
        if($(this).attr('class') === undefined){
          $(this).addClass('language-R');
        }
      });
      $('#cells').append(div);
    }
    Prism.highlightAll()
  }

  $('#btn-code').click(function(){
    $('.cell[data-cell-type="markdown"]').toggle();
    $('pre.output').toggle();
    $('.cell > img').toggle();
  });

  var notebook = getUrlParameter('nb')
  $.getJSON(notebook + '.ipynb', loadNoteBook)
});
