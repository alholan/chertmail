/**
 * CHERT Mail Custom SOGo JavaScript
 *
 * Features:
 * - Mailcow integration (login redirect, logout)
 * - RTL (Right-to-Left) support for Arabic
 * - CKEditor customization
 */

// ============================================
// MAILCOW INTEGRATION
// ============================================

// Redirect to mailcow login form
document.addEventListener('DOMContentLoaded', function () {
    var loginForm = document.forms.namedItem("loginForm");
    if (loginForm) {
        window.location.href = '/user';
    }
});

// Logout function for mailcow integration
function mc_logout() {
    fetch("/", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: "logout=1"
    }).then(() => window.location.href = '/');
}

// ============================================
// RTL (RIGHT-TO-LEFT) SUPPORT FOR ARABIC
// ============================================

/**
 * RTL Languages supported by SOGo
 * Add language codes here to enable RTL for additional languages
 */
var RTL_LANGUAGES = ['Arabic', 'العربية', 'ar', 'he', 'Hebrew', 'fa', 'Persian', 'ur', 'Urdu'];

/**
 * Detect if current language is RTL
 * Checks multiple sources: HTML lang, cookie, and body classes
 */
function isRTLLanguage() {
    // Check HTML lang attribute
    var htmlLang = document.documentElement.lang || '';
    if (htmlLang.toLowerCase().startsWith('ar') || htmlLang.toLowerCase().startsWith('he')) {
        return true;
    }

    // Check SOGo language cookie
    var cookies = document.cookie.split(';');
    for (var i = 0; i < cookies.length; i++) {
        var cookie = cookies[i].trim();
        if (cookie.startsWith('SOGoLanguage=')) {
            var lang = decodeURIComponent(cookie.substring('SOGoLanguage='.length));
            for (var j = 0; j < RTL_LANGUAGES.length; j++) {
                if (lang.toLowerCase().indexOf(RTL_LANGUAGES[j].toLowerCase()) !== -1) {
                    return true;
                }
            }
        }
    }

    // Check body for Arabic-specific text patterns (fallback)
    var bodyText = document.body ? document.body.innerText : '';
    if (bodyText && /[\u0600-\u06FF]/.test(bodyText.substring(0, 500))) {
        return true;
    }

    return false;
}

/**
 * Apply RTL layout to the document
 */
function applyRTLLayout() {
    // Set dir attribute on HTML element
    document.documentElement.setAttribute('dir', 'rtl');

    // Add RTL class to body for custom CSS targeting
    document.body.classList.add('rtl-layout');
    document.body.classList.add('chert-rtl');

    // Inject RTL-specific CSS overrides
    injectRTLStyles();

    console.log('CHERT Mail: RTL layout applied for Arabic');
}

/**
 * Inject RTL-specific CSS styles
 */
function injectRTLStyles() {
    // Check if already injected
    if (document.getElementById('chert-rtl-styles')) {
        return;
    }

    var rtlCSS = `
        /* CHERT Mail RTL Overrides for SOGo */
        [dir="rtl"] {
            text-align: right;
        }

        /* Toolbar alignment */
        [dir="rtl"] md-toolbar .md-toolbar-tools {
            flex-direction: row-reverse;
        }

        /* Sidenav positioning */
        [dir="rtl"] md-sidenav.md-locked-open {
            right: 0;
            left: auto;
        }

        /* List items */
        [dir="rtl"] md-list-item {
            flex-direction: row-reverse;
        }

        [dir="rtl"] md-list-item .md-list-item-text {
            text-align: right;
            padding-right: 16px;
            padding-left: 0;
        }

        /* Icons in list items */
        [dir="rtl"] md-list-item md-icon:first-child {
            margin-right: 0;
            margin-left: 16px;
        }

        /* Buttons */
        [dir="rtl"] .md-button md-icon + span,
        [dir="rtl"] .md-button span + md-icon {
            margin-left: 0;
            margin-right: 6px;
        }

        /* Form fields */
        [dir="rtl"] md-input-container {
            text-align: right;
        }

        [dir="rtl"] md-input-container label {
            right: 0;
            left: auto;
        }

        /* Checkboxes */
        [dir="rtl"] md-checkbox .md-label {
            margin-left: 0;
            margin-right: 30px;
        }

        /* Select dropdowns */
        [dir="rtl"] md-select-value {
            text-align: right;
        }

        /* Cards */
        [dir="rtl"] md-card-content {
            text-align: right;
        }

        /* Mail list */
        [dir="rtl"] .sg-mail-list-entry {
            flex-direction: row-reverse;
        }

        [dir="rtl"] .sg-mail-list-entry .sg-tile-content {
            text-align: right;
        }

        /* Folder list */
        [dir="rtl"] .sg-folder-list md-list-item {
            padding-right: 16px;
            padding-left: 0;
        }

        /* Calendar events */
        [dir="rtl"] .sg-event {
            text-align: right;
        }

        /* Contact cards */
        [dir="rtl"] .sg-contact-card {
            text-align: right;
        }

        /* FAB button positioning */
        [dir="rtl"] .md-fab-bottom-right {
            right: auto;
            left: 16px;
        }

        /* Scrollbar on left side for RTL */
        [dir="rtl"] ::-webkit-scrollbar {
            left: 0;
        }

        /* Toast notifications */
        [dir="rtl"] md-toast {
            right: auto;
            left: 8px;
        }

        /* Dialog buttons */
        [dir="rtl"] md-dialog-actions {
            flex-direction: row-reverse;
        }

        /* Menu items */
        [dir="rtl"] md-menu-content md-menu-item {
            text-align: right;
        }

        /* Expansion panels */
        [dir="rtl"] md-expansion-panel-header {
            flex-direction: row-reverse;
        }
    `;

    var style = document.createElement('style');
    style.id = 'chert-rtl-styles';
    style.appendChild(document.createTextNode(rtlCSS));
    document.head.appendChild(style);
}

/**
 * Initialize RTL support when DOM is ready
 */
document.addEventListener('DOMContentLoaded', function() {
    // Delay check to allow SOGo to set language
    setTimeout(function() {
        if (isRTLLanguage()) {
            applyRTLLayout();
        }
    }, 100);
});

/**
 * Also check when Angular app is ready (for SPA navigation)
 */
if (typeof angular !== 'undefined') {
    angular.element(document).ready(function() {
        setTimeout(function() {
            if (isRTLLanguage()) {
                applyRTLLayout();
            }
        }, 500);
    });
}

// ============================================
// CKEDITOR CUSTOMIZATION
// ============================================

// Change the visible font-size in the editor
CKEDITOR.addCss("body {font-size: 16px !important}");

/**
 * Configure CKEditor for RTL support
 */
CKEDITOR.on('instanceReady', function(ev) {
    var editor = ev.editor;

    // Check if RTL language is active
    if (isRTLLanguage()) {
        // Set editor content direction to RTL
        editor.config.contentsLangDirection = 'rtl';

        // Apply RTL styles to editor content
        CKEDITOR.addCss("body { direction: rtl; text-align: right; }");

        // Update editor UI direction
        if (editor.container) {
            editor.container.$.setAttribute('dir', 'rtl');
        }

        console.log('CHERT Mail: CKEditor RTL mode enabled');
    }
});

/**
 * Set default content direction based on language
 */
CKEDITOR.config.contentsLangDirection = 'ui';

// Enable spell check as you type (optional - uncomment to enable)
// CKEDITOR.config.scayt_autoStartup = true;

// ============================================
// LANGUAGE CHANGE OBSERVER
// ============================================

/**
 * Watch for language changes and reapply RTL if needed
 * This handles cases where user changes language in preferences
 */
(function() {
    var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.type === 'attributes' && mutation.attributeName === 'lang') {
                if (isRTLLanguage()) {
                    applyRTLLayout();
                } else {
                    // Remove RTL layout if language changed to LTR
                    document.documentElement.removeAttribute('dir');
                    document.body.classList.remove('rtl-layout', 'chert-rtl');
                    var rtlStyles = document.getElementById('chert-rtl-styles');
                    if (rtlStyles) {
                        rtlStyles.remove();
                    }
                }
            }
        });
    });

    // Start observing once DOM is ready
    document.addEventListener('DOMContentLoaded', function() {
        observer.observe(document.documentElement, {
            attributes: true,
            attributeFilter: ['lang']
        });
    });
})();
