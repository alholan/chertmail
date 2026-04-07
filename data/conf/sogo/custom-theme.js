/**
 * CHERT Mail Custom Theme for SOGo
 * Angular Material Theme Configuration
 *
 * Colors:
 * - Primary: #F47C4B (CHERT Orange)
 * - Secondary: #C6A87D (Sand/Brown)
 * - Background: #E9E2C7 (Light cream)
 */
(function() {
  'use strict';
  angular.module('SOGo.Common')
    .config(configure)

  configure.$inject = ['$mdThemingProvider'];
  function configure($mdThemingProvider) {
    // CHERT Mail Orange palette
    var chertOrange = $mdThemingProvider.extendPalette('orange', {
      '50': 'FFF3E0',
      '100': 'FFE0B2',
      '200': 'FFCC80',
      '300': 'FFB74D',
      '400': 'F47C4B',  // Primary CHERT Orange
      '500': 'F47C4B',
      '600': 'E86A3A',
      '700': 'D85A2B',
      '800': 'C84A1C',
      '900': 'B83A0C',
      'A100': 'FFD180',
      'A200': 'FFAB40',
      'A400': 'FF9100',
      'A700': 'FF6D00',
      'contrastDefaultColor': 'light',
      'contrastDarkColors': ['50', '100', '200', '300', 'A100', 'A200']
    });

    // CHERT Mail Sand/Brown palette
    var chertSand = $mdThemingProvider.extendPalette('brown', {
      '50': 'F5F0E6',
      '100': 'E9E2C7',
      '200': 'DDD5B0',
      '300': 'D1C899',
      '400': 'C6A87D',  // Secondary Sand color
      '500': 'C6A87D',
      '600': 'B89A6F',
      '700': 'A88C61',
      '800': '987E53',
      '900': '887045',
      'A100': 'F5F0E6',
      'A200': 'E9E2C7',
      'A400': 'C6A87D',
      'A700': 'A88C61',
      'contrastDefaultColor': 'dark'
    });

    // Background palette (light cream)
    var chertBackground = $mdThemingProvider.extendPalette('grey', {
      '50': 'FFFFFF',
      '100': 'F9F6F0',
      '200': 'F5F0E6',
      '300': 'E9E2C7',
      '400': 'DDD5B0',
      '500': 'CCCCCC',
      '600': 'BBBBBB',
      '700': '999999',
      '800': '666666',
      '900': '333333',
      'A100': 'FFFFFF',
      'A200': 'F5F0E6',
      'A400': 'E9E2C7',
      'A700': '999999',
      '1000': '4A4A4A'
    });

    // Register custom palettes
    $mdThemingProvider.definePalette('chert-orange', chertOrange);
    $mdThemingProvider.definePalette('chert-sand', chertSand);
    $mdThemingProvider.definePalette('chert-background', chertBackground);

    // Apply CHERT Mail theme
    $mdThemingProvider.theme('default')
      .primaryPalette('chert-orange', {
        'default': '500',
        'hue-1': '300',
        'hue-2': '600',
        'hue-3': 'A700'
      })
      .accentPalette('chert-sand', {
        'default': '500',
        'hue-1': '300',
        'hue-2': '600',
        'hue-3': 'A700'
      })
      .backgroundPalette('chert-background');

    // Disable on-demand theme generation for performance
    $mdThemingProvider.generateThemesOnDemand(false);
  }
})();
