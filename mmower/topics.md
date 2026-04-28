== Implementing a Conversation System

A common requirement in IF games is conversation with NPCs. Here is a sample implementation of a conversation system.

We make use of `@inventory` and `@item` to implement what the NPC knows about and `@card` for displaying conversation elements. In this context the inventory is kind of the NPCs memory and the items are individual things they know and/or can talk about.

Let's set things up:
....

@actor sam_spade {
  topic_inventory_id: #inv_sam_spade_topics

  topics: function() {
    return this.topics_inventory.getItemsForSlot("slot_topics");
  }
}

@slot slot_topics {
  accepts: :topic
}

@inventory inv_sam_spade_topics {
  slots: #{#slot_topics}
}

@elem topic = item

@defaults topic {
  type: :topic
  read: false

  sname: "topic name"
  card_id: _
}
....

We've created an inventory with a slot that holds items of type `topic `. And we've created an element alias `topic` that is an item with a type compatible with the slot. Let's create a few things Sam can talk about:

....

@inventory inv_sam_spade_topics {
  slots: #{#slot_topics}
  initial_contents: {topics_slot: [#t_who_is_miles_archer]}
}

@topic t_who_is_miles_archer {
  title: "Who is Miles Archer?"
  card_id: #c_who_is_miles_archer
  leads_to: [#t_who_killed_miles]
}

@card c_who_is_miles_archer {
  bindings: [
    player: #player
    sam: #sam_spade
  ]
  content: ```
  <.dialog speaker={player}>Who was Miles Archer?</.dialog>
  <.dialog speaker={sam}>Miles was my partner, not my friend. But he was my partner, and when someone kill's your partner, you're supposed to do something about it. That's the way it works.</.dialog>
  ```
}

@topic t_who_killed_miles {
  title: "Who killed Miles?"
  card_id: #c_who_killed_miles
}

@card c_who_killed_miles {
  bindings: [
    player: #player
    sam: #sam_spade
  ]
  content: ```
  <.dialog speaker={player}>Who killed Miles?</.dialog>
  <.dialog speaker={sam}>That's what I'm going to find out. Miles got himself shot in the back in Burritt Alley last night. Could've been the man we were tailing - Floyd Thursby - but somebody put a bullet in him too, about twenty minutes later.</.dialog>
  ```
}
....

We've added two topics you can talk to Sam Spade about. But only one is available at the beginning of the game (the initial contents of the topics slot). Each topic has an associated card that is used to present related dialog to the player. Now how would we make use of this?

....
@component topics (bindings, assigns, content) => {
  const {actor} = assigns;

  const topicLinks = actor.topics().map(
    (topic) => {
      const textClass = topic.read ? "has-text-grey" : "has-text-link";
      return `<li><a data-event="selected_topic" data-topic-id="${topic.id} class="${textClass}">${topic.title}</a></li>`;
    }
  );

  return `<ul>${topicLinks}</ul>`;
}

@scene sc_conversation {
  actor_id: _

  layout_mode: :stack
  layout: ```
  <div class="columns is-centered">
    <div class="rez-front-face column is-one-fifth">
      <.topics actor={scene.actor} />
    </div>
    <div class="column">${content}</div>
  </div>
  ```

  initial_card_id: #c_start_conversation

  on_start: (scene, params) => {
    const {actorId} = params;
    scene.actor_id = actorId;
  }

  on_selected_topic: (scene, params) => {
    const {topicId} = params;
    const topic = $t(topicId, "item", true);
    topic.read = true;
    if(topic.leads_to) {
      topic.leads_to.forEach((relatedTopicId) => {
        scene.actor.addTopic(relatedTopicId)
      });
    }
    return RezEvent.playCard(topic.card_id);
  }
}

@card c_start_conversation {
  content: ```
  <p class="block">What do you want to talk to ${scene.actor.name} about?</p>
  ```
}
....

The scene has a two-column layout. Topics are presented in the left-hand column. The `.topics` component is used to keep the topic processing code tucked away. The player can select a topic by clicking its link and we track whether the topic has already been viewed (potentially we could reset this if the actor has more to say on that topic later on).

Instead of using normal `data-event="card"` we use a custom `data-event="selected_topic"` event that we handle in the conversation scene. This does two things:

* we can record that the topic has been used
* we can add new topics to the actors knowledge

When the player accesses a topic with the `lead_to:` attribute, it adds those related topics to those the actor presents to the player.

Otherwise we use the standard card loading mechanism, and the scene uses the stack layout so that each conversation card is presented one after another.