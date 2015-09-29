'use strict';

var myApp = angular.module('myApp', ['ngRoute']);

myApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/paints', {
        templateUrl: 'templates/paints.html',
        controller: 'PaintsController'
      }).
      when('/compatibility', {
        templateUrl: 'templates/compatibility.html',
        controller: 'PaintsController'
      }).
      when('/manage', {
        templateUrl: 'templates/manage.html',
        controller: 'PaintsController'
      }).
      when('/login', {
        templateUrl: 'templates/login.html',
        controller: 'LoginController'
      }).
      when('/signup', {
        templateUrl: 'templates/signup.html',
        controller: 'SignupController'
      }).
      when('/logout', {
        templateUrl: 'template/login.html',
        controller: 'LoginController'
      }).
      otherwise({
          redirectTo: '/login'
      });
  }]);

myApp.controller('PaintsController', ['$scope', '$http', function($scope, $http) {
    $http({method: 'GET', url: '/sync.json'}).
      success(function(data, status, headers, config) {
        $scope.paints = data.paint;
        $scope.brands = data.brand;
        $scope.paint_ranges = data.paint_range;
        $scope.status_keys = data.status_key;
        $scope.compatibility_groups = data.compatibility_groups;

        var range_brand_hash = {};
        for (var i = 0; i < $scope.paint_ranges.length; i++) {
            range_brand_hash[$scope.paint_ranges[i].id] = $scope.paint_ranges[i].brand_id;
        }

        for (var i = 0; i < $scope.paints.length; i++) {
            var range_id = $scope.paints[i].range_id;
            $scope.paints[i].brand_id = range_brand_hash[range_id]
        }

        for (var i = 0; i < $scope.compatibility_groups.length; i++) {
          var group = $scope.compatibility_groups[i];
          group.range = [];
          var paints = $scope.compatibility_groups[i].paint_id;
          if (paints) {
            for (var p = 0; p < paints.length; p++) {
              var paint = $scope.GetPaint(paints[p]);
              group.range[paint.range_id] = paint;
            }
          }
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

    $scope.GetPaint = function(id) {
      for (var i = 0; i < $scope.paints.length; i++) {
        if ($scope.paints[i].id === id) {
          return $scope.paints[i];
        }
      }
      return null;
    }

    $scope.AddBrand = function(brandName) {
      var post_data = "name=" + brandName;
      $http({method: 'POST',
             url: '/brands',
             data: post_data,
             headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
        success(function(data, status, headers, config) {
        }).
        error(function(data, status, headers, config) {
        });
    }

    $scope.AddBrandJson = function(json) {
      var post_data = "json=" + JSON.stringify(JSON.parse(json));
      $http({method: 'POST',
             url: '/brands.json',
             data: post_data,
             headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
        success(function(data, status, headers, config) {
        }).
        error(function(data, status, headers, config) {
        });
    }

    $scope.AddRange = function(brand, rangeName) {
      var post_data = "brand_id=" + brand.id + "&name=" + rangeName;
      $http({method: 'POST',
             url: '/ranges',
             data: post_data,
             headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
        success(function(data, status, headers, config) {
        }).
        error(function(data, status, headers, config) {
        });
    }

    $scope.AddRangeJson = function(json) {
      var post_data = "json=" + JSON.stringify(JSON.parse(json));
      $http({method: 'POST',
             url: '/ranges.json',
             data: post_data,
             headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
        success(function(data, status, headers, config) {
        }).
        error(function(data, status, headers, config) {
        });
    }

    $scope.AddPaint = function(range, paintName, paintColor) {
      var post_data = "range_id=" + range.id + "&name=" + paintName + "&color=" + paintColor;
      $http({method: 'POST',
             url: '/paints',
             data: post_data,
             headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
        success(function(data, status, headers, config) {
        }).
        error(function(data, status, headers, config) {
        });
    }

    $scope.AddPaintJson = function(json) {
      var post_data = "json=" + JSON.stringify(JSON.parse(json));
      $http({method: 'POST',
             url: '/paints.json',
             data: post_data,
             headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
        success(function(data, status, headers, config) {
        }).
        error(function(data, status, headers, config) {
        });
    }

    $scope.NewCompatibilityGroup = function() {
        $scope.compatibility_groups.push({id: 0});
    };

    $scope.UpdateCompatibilityGroup = function(group, paint) {
      var post_data = "json=" + JSON.stringify({id: group.id, paint_id: [paint.id]});

      $http({method: 'POST',
             url: '/paint_groups.json',
             data: post_data,
             headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
        success(function(data, status, headers, config) {
          group.id = data['id'];
        }).
        error(function(data, status, headers, config) {

        });
    };
}]);

myApp.controller('LoginController', ['$http', '$window', '$location', function($http, $window, $location) {
  this.login = function(emailAddress, password) {
    var postData = 'email=' + emailAddress + '&password=' + password;
    $http({method: 'POST',
           url: '/login',
           data: postData,
           headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
      success(function(data, status, headers, config) {
        $window.sessionStorage.token = data.auth_token;
        $location.path('paints');
      }).
      error(function(data, status, headers, config) {

      });
  };
  this.loggedIn = function() {
    return !!$window.sessionStorage.token;
  };
  this.logout = function() {
    delete $window.sessionStorage.token;
    $location.path('/');
  };
}]);

myApp.controller('SignupController', ['$http', function($http) {
  this.signup = function(emailAddress, password, confirmPassword) {
    var postData = 'email=' + emailAddress + '&password=' + password;
    $http({method: 'POST',
           url: '/user.json',
           data: postData,
           headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).
      success(function(data, status, headers, config) {

      }).
      error(function(data, status, headers, config) {

      });
  };
}]);

myApp.factory('authInterceptor', function($window) {
  return {
    request: function(config) {
      config.headers = config.headers || {};
      if ($window.sessionStorage.token) {
        config.headers.Authorization = $window.sessionStorage.token;
      }
      return config;
    }
  };
});

myApp.config(function($httpProvider) {
  $httpProvider.interceptors.push('authInterceptor');
});

myApp.directive('paintListing', function() {
  return {
    restrict: 'A',
    templateUrl: 'templates/paint-listing.html',
  };
});
