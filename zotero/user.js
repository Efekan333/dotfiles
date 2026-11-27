// Zotero prefs, copied into prefs.js on every start (user.js wins over UI changes).
// Linked into the profile by scripts/link-zotero.sh.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // load chrome/user*.css
user_pref("browser.theme.toolbar-theme", 0);                   // View → Appearance: 0 dark, 1 light, 2 system
user_pref("extensions.zotero.reader.contentDarkMode", true);   // reader follows the dark scheme
