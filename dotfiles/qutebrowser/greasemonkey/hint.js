(function() {
    'use strict';

    // const old_add_event_listener = Element.prototype.addEventListener;
    // Element.prototype.addEventListener = function() {
    //     if (arguments[0] === 'click') {
    //         this.classList.add('qutebrowser-custom-click');
    //     }
    //     return old_add_event_listener.apply(this, arguments);
    // };
    //
    const host = window.location.host;

    if (host === 'chat.deepseek.com') {
        window.addEventListener('load', function() {
            let target = "开启新对话";
            let walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null);
            let node;
            while (node = walker.nextNode()) {
                if (node.nodeType === Node.TEXT_NODE && node.nodeValue === target) {
                    node.parentNode.classList.add('qutebrowser-custom-click');
                }
            }
        });
    }
})();
