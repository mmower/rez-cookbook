# Map Library (v0.1.0)
# by Matt Mower <self@mattmower.com>

Maps are a quintessential element of much of interactive fiction but less so in
choice based fiction, at least as a game concept. The map is usually implicit in
the links that you follow from passage to passage.

One way to look at the map is that it is the passage (`@card`) content because that
is what the player see's. However this quickly becomes problematic when you want
multiple cards to be played while the player maintains a location. Also when you
want to make the connection between locations dynamic (for example, a locked door
barring an exit). This all happens quite naturally in a parser game but is often
a manual chore in a choice game.

This map library gives Rez a `@location` concept that describes where the player
is located along with other places that are reachable.

## Installation

rez cookbook get mmower/maps

## Configuration

Maps assumes you define a least `@actor` with id `#player` that represents the player
and their location. For this reason the add a `location_id:`


```
@actor player {
  $global: true
  location_id: _
  last_location_id: _
}
```

### Elements

## Location

`@elem location = card`

The `@location` element is a type of `@card` that represents a location in the map.

When a `@location` card is played it sets the `#player` `location_id` and `last_location_id`.

Every time a `@location` card is played, two events are fired, with no params:

* `player_enters` on the destination `@location`
* `changed_location` on `#player`

These fire unconditionally, even if the location is the same as the one the player is
already in (e.g. a "look around" action that replays the current location's card).

`@location`'s default `on_player_enters` handler increments `visit_count`. Since it runs
before any location-specific `on_player_enters` handler you add, `visit_count` has
already been incremented by the time your handler runs — check `location.visit_count === 1`
to detect a first-time visit. You can layer additional behaviour on top with:

```
@location my_location {
  on_player_enters: +(location) => {
    %% your custom behaviour
  }
}
```

For behaviour that should run regardless of which location was entered — quest
triggers, UI updates, and so on — hook `#player`'s `changed_location` event instead:

```
@actor player {
  on_changed_location: +(player, params) => {
    %% your custom behaviour
  }
}
```

Handlers receive no params; read `location.id`, `player.location_id`, and
`player.last_location_id` directly.

| Attribute   | Required | Description                                   |
|-------------|----------|-----------------------------------------------|
| zone_id     |     Y    | The id of the @zone the location belongs to   |
| int_name    |     Y    | Name of the location when you are in it       |
| ext_name    |     Y    | Name of the location when you are elsewhere   |
| exits       |     Y    | List of @location ids you can reach from here |
| reachable   |     Y    | Can you reach this location?                  |

## Zone

`@elem zone = object`

The `@zone` element is used to define a grouping of `@location`s. It caches those locations
for fast lookup.

| Attribute   | Required | Description                                   |
|-------------|----------|-----------------------------------------------|
| label       |     Y    | Description of the zone                       |
