'use strict';

var myApp = angular.module('myApp', []);

myApp.controller('PaintsController', ['$scope', '$http', function($scope, $http) {
    $http({method: 'GET', url: '/sync.json'}).
      success(function(data, status, headers, config) {
        $scope.paints = data.paint;
        $scope.brands = data.brand;
        $scope.paint_ranges = data.paint_range;
        $scope.status_keys = data.status_key;
      }).
      error(function(data, status, headers, config) {
        $scope.paints = "ERROR";
      });
}]);