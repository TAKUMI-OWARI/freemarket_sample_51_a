//リロードしても検索フォームの値が残る(検索フォームの値はsessionStorageに保存される)
window.onbeforeunload = function() {
  sessionStorage.setItem("name", $('#inputName').val());
}
window.onload = function() {
  var name = sessionStorage.getItem('name');
  if(name !== null)$('#inputName').val(name);
  if(name == 'undefined')$('#inputName').val("");
}
//検索ページにおいて、リロードすると検索フォームの値がsubmitされ、検索結果が再描画される
document.addEventListener("DOMContentLoaded", function(event) {
  if (window.document.body.id === "product_search_page") {
    if (window.performance) {
      if (performance.navigation.type === 1) {
        var name = sessionStorage.getItem('name');
        if(name !== null)$('#inputName').val(name);
        $('#search_form').submit();
      }
    }
  }
});
//商品検索フォームでEnterキーを押すと実行される
function enter(){
  if( window.event.keyCode == 13 ){
    document.form1.submit();
  }
}
//検索フォームをクリックすると、枠線の色が変化する
$(document).on('turbolinks:load', function() {
  $('#inputName').on('click', function() {
    $(this).addClass('touchForm');
  });
})
//検索フォーム以外をクリックすると、検索フォームの枠線の色が元の色に戻る
$(document).click(function(e){
  if(!$(e.target).is('#inputName')) {
    $('#inputName').removeClass('touchForm');
  }
});