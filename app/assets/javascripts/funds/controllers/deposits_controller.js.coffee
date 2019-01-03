app.controller 'DepositsController', ['$scope', '$stateParams', '$http', '$filter', '$gon', ($scope, $stateParams, $http, $filter, $gon) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.currencyTranslationLocals = currency: $stateParams.currency.toUpperCase()
  $scope.current_user = current_user = $gon.user
  $scope.name = current_user.name
  $scope.bank_details_html = $gon.bank_details_html
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.depositfile = ''
  $scope.currencyType =
    if _.include(gon.fiat_currencies, $scope.currency) then 'fiat' else (if $scope.currency == 'grin' then 'mw_coin' else 'coin')

  $scope.$watch (-> $scope.account.deposit_address), ->
    setTimeout(->
      $.publish 'deposit_address:create'
    , 1000)

  $scope.fileChange = (element) ->
    $scope.depositfile = element.files[0];

  $scope.uploadFile = ->
    file = $scope.depositfile;
    fd = new FormData();
    fd.append('file', file);

    $http.post("/deposits/#{$scope.currency}/upload", fd, {
       transformRequest: angular.identity,
       headers: {'Content-Type': undefined}
    }) .error (responseText) ->
        $.publish 'flash', { message: responseText }
]
