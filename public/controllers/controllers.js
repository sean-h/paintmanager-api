'use strict';

var myApp = angular.module('myApp', ['ngRoute']);

myApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/paints', {
        templateUrl: 'templates/paints.html',
        controller: 'PaintsController'
      }).
      otherwise({
          redirectTo: '/paints'
      });
  }]);

myApp.controller('PaintsController', ['$scope', '$http', function($scope, $http) {
    $http({method: 'GET', url: '/sync.json'}).
      success(function(data, status, headers, config) {
        $scope.paints = data.paint;
        $scope.brands = data.brand;
        $scope.paint_ranges = data.paint_range;
        $scope.status_keys = data.status_key;

        var range_brand_hash = {};
        for (var i = 0; i < $scope.paint_ranges.length; i++) {
            range_brand_hash[$scope.paint_ranges[i].id] = $scope.paint_ranges[i].brand_id;
        }

        for (var i = 0; i < $scope.paints.length; i++) {
            var range_id = $scope.paints[i].range_id;
            $scope.paints[i].brand_id = range_brand_hash[range_id]
        }

        $scope.list_page = 0;
        $scope.paints_per_page = 20;

      }).
      error(function(data, status, headers, config) {
        $scope.paints = "ERROR";
      });

    $scope.UpdatePaintStatus = function(paint, statusID) {
        var old_status = paint.status;
        paint.status = statusID;
        var post_data = "paint_id=" + paint.id +
                       "&status=" + paint.status;
        $http({method: 'POST',
               url: '/paint_statuses',
                data: post_data,
               headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
            success(function(data, status, headers, config) {
            }).
            error(function(data, status, headers, config) {
                paint.status = old_status;
                window.alert("Error Connecting to Server");
            });
    };
}]);
