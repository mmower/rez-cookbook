# Actions Library (v0.2.0)

This library is a flexible "inverse parser" style action library.

What that means is that, at any given point, the library will enumerate all of
the actions that are available to the player and present them.

## Action Definition

You define an action using the `@action` element that is provided by the library.
You can have as many `@action`s as makes sense in your game.

Example:

Here is an `@action` that generates links for talking to `@actor` NPCs.

````
@action act_talk {
  label: "talk"
  verb: "Talk"
  determiner: "to"
  menu: "conversation"

  event: "interlude"
  target: "conversation_scene"

  objects: function() {
    const is_local_actor = (actor) => !actor.$template && actor !== $player && actor.location_id == $player.location_id;
    return $game.getAll("actor").filter(is_local_actor);
  }

  available: function(decision, actor) {
    actor.will_talk_to(decision, $player);
  }
}
````

The `label:` attribute is an internal description while the `verb:` attribute is a player-
facing description of the action.

The `menu:` attribute is used to group related actions together. In this case "conversation"
links.

The `determiner:` attribute is used by the default link formatter to join together the verb and the object, e.g. "Talk to Brian", "Open the airlock".

The `event:` and `target:` attributes determine what happens if the player clicks on this link when it is active. The specified event is sent:

* card - play the card whose id is in `target:`
* switch - start the scene whose id is in `target:`
* interlude - start an interlude with the scene whose id in `target:`

Any other event is sent as a custom event, e.g. `event: :shout` will sent a `shout` event.

The target is most often the id of the object being triggered by the event but can also be
`object` where the event is sent to the object or `self` where the event is sent to the action.

For example:
```
@action act_talk {
  event: "speak"
  target: :self

  on_speak: (action, params) => {
    // Implement action event code here
  }
}
```

Here when the link is clicked the `on_speak` handler will run on the action itself.

The `objects:` attribute returns a (possibly empty) array of objects that the `@action` can
be applied to. In the given example that is `@actor`s that are not the player but in the
players location.

The `available:` attribute determins whether the action should be available for a given
object and uses the provided RezDecision to determine the result for that object. The result should be a call to one of `decision.yes()`, `decision.no("reason")`, or `decision.hide()`.

For action forcing use `decision.yes({force: true})`. If at least one action is being
forced then only forced actions will be available.

## Action Generation

The `action_manager` object handles collecting and presenting available actions in conjection
with two provided components `<.action_links />` and `<.action_menu />`.

The `action_manager` iterates through all `@action` elements first calling their `objects:` function to see if they apply to any objects and then the `available:` function to see which objects it is available for.

## Link Formatting

Basic link formatting involves overriding some of the `@action` defaults in your actions.

### params_for

By defining `params_for: function(obj)` in your `@action` you can set data parameters that
get passed in the link that is generated.

### obj_name

When formatting a link the `@action` obj_name will be called with the object. The default
implementation looks for a `name`, `int_name`, or `sdesc` property. You can either define
one of these or override to return whatever property you like.

### link_text

This returns the actual text of the link. The default uses "<verb> <determiner> <name>" but you can override to return any text you like.

### build_link

This returns a `RezActionLink` instance to represent a link for this action. For this level of
customisation see the source in actions.rez.

## Link Presentation

Links are presented using the `action_manager` provided in the library and published as a global
`$action_manager`. The process involves two stages:

1. Generating available actions
2. Converting actions into markup

The `action_manager` has a `build_actions:` function attribute that uses the mechanisms described
above to create a map of `RezActionLink` objects representing all of the available actions. The map keys are menu names where the values are an array of links for that menu.

Link menus can be converted into markup using either the `<.action_links />` or `<.action_menu />` `@component`s provided. Or you can use them as the basis for your own custom component.

The default menus are formatted as unordered lists of links, with a menu title.

The default formatters are in the `action_manager` as `default_format_link` and `default_format_menu`. To override formatting for a specific menu implement one or more
of the following attributes. For a menu 'action':

```
format_action_link: function(link) {
    return `<li class="action">${link.tag()}</li>`;
  }
```

To override formatting of a specific menu:

```
format_action_menu: function(menu, links) {
    const items = links.map((link) => this.format_link(menu, link)).join("");
    const list = `<ul class="action">${items}</ul>`;

    const menuName = menu.toTitleCase();
    const heading = `<h3 class="is-size-1">To ${menuName}</h3>`;

    return `${heading}${list}`;
  }
```

## Unavailable Actions

When an action is unavailable, but not hidden, you can return the reason why (e.g. the
player lacks some object or stat). This can either be presented in the link text (the
default) or via some other means. For example, if you have Tippy.js installed, you can
present the reason in a Tippy tooltip by setting:

```
RezActionLink.inactiveTagRenderer = RezActionLink.tippyInactiveTag;
```

To use some other method see the actions.rez and implement a different inactive tag
renderer.
