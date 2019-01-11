app.controller 'DepositsController', ['$scope', '$stateParams', '$http', '$filter', '$gon', ($scope, $stateParams, $http, $filter, $gon) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.currencyTranslationLocals = currency: $stateParams.currency.toUpperCase()
  $scope.current_user = current_user = $gon.user
  $scope.name = current_user.name
  $scope.bank_details_html = $gon.bank_details_html
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.depositfile = null
  $scope.currencyType =
    if _.include(gon.fiat_currencies, $scope.currency) then 'fiat' else (if $scope.currency == 'grin' then 'mw_coin' else 'coin')

  $scope.$watch (-> $scope.account.deposit_address), ->
    setTimeout(->
      $.publish 'deposit_address:create'
    , 1000)

  $scope.fileChange = (element) ->
    $scope.depositfile = element.files[0];

  $scope.uploadFile = ->
    file = $scope.depositfile

    if file
      reader = new FileReader

      reader.addEventListener 'load', (event) ->
        slateFile = event.target

        if isValidJSON slateFile.result
          fileJSON = JSON.parse slateFile.result

          if fileJSON
            fd = new FormData();
            fd.append('fileJSON', JSON.stringify fileJSON);

            $http.post("/deposits/#{$scope.currency}/upload", fd, {
              transformRequest: angular.identity,
              headers: {'Content-Type': undefined}
            }).error (responseText) ->
              $.publish 'flash', { message: responseText }
          return

        console.error 'FILE IS INVALID'
        $.publish 'flash', { message: 'File is invalid' } # TODO @jsaints i18n
        false

      reader.readAsText file

  isValidJSON = (str) ->
    if str
      try
        JSON.parse str
      catch e
        return false
      return true
    false
]
