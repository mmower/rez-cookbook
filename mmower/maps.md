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
