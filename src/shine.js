import { init, classModule, propsModule, styleModule, eventListenersModule, h } from "snabbdom";

const patch = init([
    // Init patch function with chosen modules
    classModule, // makes it easy to toggle classes
    propsModule, // for setting properties on DOM elements
    styleModule, // handles styling on elements with support for animations
    eventListenersModule, // attaches event listeners
]);

function convertList(list, updateCallback) {
    if (list.length > 1) {
        return [convert(list[0], updateCallback), ...convertList(list[1], updateCallback)];
    } else if (list.length == 1) {
        return [convert(list[0], updateCallback)];
    } else {
        return [];
    }
}

function convertAttribute(attrs, attribute, updateCallback) {
    switch (attribute.type) {
        case "OnClick":
            attrs["on"] = { click: () => updateCallback(attribute["0"]) };
            break;
    }
}

function convertAttributes(attributeList, updateCallback) {
    const attrs = {};

    let list = [...attributeList];
    while (list.length) {
        if (list.length > 1) {
            convertAttribute(attrs, list[0], updateCallback);
            list = list[1];
        } else if (list.length == 1) {
            convertAttribute(attrs, list[0], updateCallback);
            list = [];
        }
    }

    return attrs;
}

function convert(entry, updateCallback) {
    switch (entry.type) {
        case "Node":
            return h(
                entry.node,
                convertAttributes(entry.attributes, updateCallback),
                convertList(entry.children, updateCallback)
            );
        case "Text":
            return entry["0"];
    }
}

export function renderDom(target, output, updateCallback) {
    const previous =
        target.type === "VirtualDomTarget" ? target["0"] : document.getElementById(target["0"]);
    const next = convert(output, (msg) => updateCallback(msg, next));
    patch(previous, next);
}

export function intToString(int) {
    return int.toString();
}
