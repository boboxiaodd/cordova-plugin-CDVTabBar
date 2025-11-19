var exec = require('cordova/exec');


function TabBar() {
    this.tag = 0;
    this.callbacks = {};
    this.selectedItem = null;
    this.isShow = false;
}

/**
 * Create a native tab bar that can have tab buttons added to it which can respond to events.
 *
 * @param options Additional options:
 *   - selectedImageTintColorRgba: Tint color for selected items (defaults to standard light blue), must define the
 *     color as string e.g. '255,0,0,128' for 50% transparent red. This is only supported on iOS 5 or newer.
 *   - tintColorRgba: Tint color for the bar itself (value as above)
 */
TabBar.prototype.create = function (options) {
    cordova.exec(null,null,"TabBar","create", options || {});
};

/**
 * Create a new tab bar item for use on a previously created tab bar.  Use ::showTabBarItems to show the new item on the tab bar.
 *
 * If the supplied image name is one of the labels listed below, then this method will construct a tab button
 * using the standard system buttons.  Note that if you use one of the system images, that the \c title you supply will be ignored.
 *
 * <b>Tab Buttons</b>
 *   - tabButton:More
 *   - tabButton:Favorites
 *   - tabButton:Featured
 *   - tabButton:TopRated
 *   - tabButton:Recents
 *   - tabButton:Contacts
 *   - tabButton:History
 *   - tabButton:Bookmarks
 *   - tabButton:Search
 *   - tabButton:Downloads
 *   - tabButton:MostRecent
 *   - tabButton:MostViewed
 * @param {String} name internal name to refer to this tab by
 * @param label
 * @param {String} [image] image filename or internal identifier to show, or null if now image should be shown
 * @param {Object} [options] Options for customizing the individual tab item
 *  - \c badge value to display in the optional circular badge on the item; if null or unspecified, the badge will be hidden
 */
TabBar.prototype.createItem = function (name, label, image, options) {

    let tag = this.tag++;
    if (options && 'onSelect' in options && typeof (options['onSelect']) == 'function') {
        this.callbacks[tag] = {'onSelect': options.onSelect, 'name': name};
    }

    cordova.exec(null, null, "TabBar", "createItem", [name, label, image, tag, options]);
};

/**
 * Function to detect currently selected tab bar item
 * @see createItem
 * @see showItems
 */
TabBar.prototype.getSelectedItem = function () {
    return this.selectedItem;
};

/**
 * Hide a tab bar.  The tab bar has to be created first.
 */
TabBar.prototype.hide = function (animate) {
    if (animate === undefined || animate === null)
        animate = true;
    cordova.exec(null,null,"TabBar","hide", [animate]);
    this.isShow = false;
};

/**
 * Must be called before any other method in order to initialize the plugin.
 */
TabBar.prototype.init = function () {
    cordova.exec(null,null,"TabBar","init",[]);
};

/**
 * Internal function called when a tab bar item has been selected.
 * @param {Number} tag the tag number for the item that has been selected
 */
TabBar.prototype.onItemSelected = function (tag) {
    this.selectedItem = tag;
    if (typeof (this.callbacks[tag].onSelect) == 'function')
        this.callbacks[tag].onSelect(this.callbacks[tag].name);
};

TabBar.prototype.resize = function () {
    cordova.exec(null,null,"TabBar","resize",[]);
};

/**
 * Manually select an individual tab bar item, or nil for deselecting a currently selected tab bar item.
 * @see createItem
 * @see showItems
 * @param tab
 */
TabBar.prototype.selectItem = function (tab) {
    cordova.exec(null,null,"TabBar","selectItem", [tab]);
};

/**
 * Show a tab bar.  The tab bar has to be created first.
 * - \c height integer indicating the height of the tab bar (default: \c 49)
 * - \c position specifies whether the tab bar will be placed at the \c top or \c bottom of the screen (default: \c bottom)
 */
TabBar.prototype.show = function () {
    cordova.exec(null, null, "TabBar", "show", []);
    this.isShow = true;
};

/**
 * Show previously created items on the tab bar
 * @param {String} arguments... the item names to be shown
 *  - \c animate indicates that the items should animate onto the tab bar
 * @see createItem
 * @see create
 */
TabBar.prototype.showItems = function () {
    let parameters = [];
    for (let i = 0; i < arguments.length; i++) {
        parameters.push(arguments[i]);
    }
    cordova.exec(null, null, "TabBar", "showItems", [parameters]);
};

/**
 * Update an existing tab bar item to change its badge value.
 * @param {String} name internal name used to represent this item when it was created
 * @param {Object} options Options for customizing the individual tab item
 *  - \c badge value to display in the optional circular badge on the item; if null or unspecified, the badge will be hidden
 */
TabBar.prototype.updateItem = function (name, options) {
    if (!options) options = {};
    cordova.exec(null, null, "TabBar", "updateItem", [name, options]);
};

cordova.addConstructor(function () {
    if (!window.plugins)
        window.plugins = {};

    window.plugins.tabBar = new TabBar();
});
