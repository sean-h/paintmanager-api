'use strict';

var myApp = angular.module('myApp', []);

myApp.controller('PaintsController', ['$scope', '$http', function($scope, $http) {
    $http({method: 'GET', url: '/paints.json'}).
      success(function(data, status, headers, config) {
        $scope.paints = data;
      }).
      error(function(data, status, headers, config) {
        $scope.paints = "ERROR";
      });
}]);
