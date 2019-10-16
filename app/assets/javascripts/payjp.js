$(function() {
  $(document).on("click", "#token_submit", function(e) {
    e.preventDefault();
    var form = $("#charge_form");
    Payjp.setPublicKey("pk_test_8da00aba5ee999041f3a784e");
    form.find("input[type=submit]").prop("disabled", true);
    var card = {
      number: parseInt($("#number").val()),
      cvc: parseInt($("#cvc").val()),
      exp_month: parseInt($("#exp_month").val()),
      exp_year: parseInt($("#exp_year").val())
    };
    Payjp.createToken(card, function(status, response) {
      if (status == 200) {
        $("#number").removeAttr("name");
        $("#cvc").removeAttr("name");
        $("#exp_month").removeAttr("name");
        $("#exp_year").removeAttr("name");
        form.append($('<input type="hidden" name="payjp-token">').val(response.id));
        form.get(0).submit();
        alert("登録が完了しました");
      } else {
        alert("カード情報が正しくありません。") 
      }
    });
  });
});