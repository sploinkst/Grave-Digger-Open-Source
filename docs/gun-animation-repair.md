Gun animation repair
====================

The shared binder preserves each gun's authored actions, discovers all sequence-only clips, resolves variant families, and keeps explicit omissions. Studio uses embedded sequences instead of inaccessible uploaded IDs. Live games use published AnimationIds or a PublishedAnimationId attribute on the wrapper/sequence. Grace draw is only a fallback when a pistol has no draw of its own.

Every firearm's event-only animation wait now has a timeout and cancels on weapon replacement. Volk's cycle speed no longer depends on an unloaded track's zero Length.

Validation: all 493 clips in the supplied inventory are covered by the actual binder test, and the firearm scripts compile with the Luau compiler. These checks do not establish that Roblox permits the experience to load the uploaded assets.

Use sync.project.json to sync the game code and restart Play. For published play, run tools/audit-gun-animations.luau in Studio's Edit-mode Command Bar. It reports missing publication IDs, failed fetches, and folders without embedded sequences. Publish authored animations under the experience owner (or grant the experience permission to existing animations), then set each Animation.AnimationId or its sequence's PublishedAnimationId attribute. Save and publish those asset changes too. Local registered hashes cannot be used on live servers.

KnellRevolver and KnellBanditRevolver contain no keyframe sequences in the supplied inventory. Their existing uploaded wrappers or the legacy pieper folder must supply their clips.
