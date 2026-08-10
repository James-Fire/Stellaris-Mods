# Situations System
# -----------------------
#
# The Situations system is used to for tracking and interacting with ongoing stories in your empire.
# A planetary revolt, a starbase slowly falling into a black hole, or an empire-wide resource deficit are all examples of possible situations.
#
# Situations always have:
# 	- A TARGET (typically a single colony carrier, your whole empire, or no target)
# 	- A PROGRESS BAR that goes from 0 to 100, split in one or more STAGES
# 	- Different APPROACHES used to define how to interact with the ongoing event
# 	- Monthly EVENTS, both random and fixed
# 	- One or two ENDINGS triggering when the progress bar reaches 0 and/or 100
#
# This complex, flexible system allows you to craft a huge variety of situations.
# You could have a situation starting from 100 where you are trying to *reduce* progress, for example,
# or one where you start from the middle and have to choose between two contrasting goals.
# The system is has lots of moving parts, so let's examine them one at a time.
#
#
# BASIC SETUP
# -----------------------
# All scopes are this/root = situation. You can scope to owner for the country or target for the target.
# Situations typically target a colony carrier or a country. If no target is set, the UI will indicate your empire (but "target = { }" in script will not work).
# Targeting other scopes, while possible, breaks triggered target modifiers, so target with caution.
# AI empires can also be target of Situations. This can be useful to simulate complex behaviours.
# Mercenary Enclaves in Overlord, for example, use a situation players will never see to handle patron rewards.
#
# test_situation = {					#For loc strings, you need to define "test_situation", "test_situation_type", "test_situation_desc", and "test_situation_monthly_change_tooltip"
# 										#first is the name while the Situation exists. It can use [Target.GetName] and so on),
# 										#The _type key is used in cases where the Situation does not exist yet,
# 										#specifically the start_situation effect's tooltip (stuff like [Target.GetName] will not work there.)
# 										#The monthly_change_tooltip describes what the player can do to affect the situation's progress.
#										#It can be seen when tooltipping over the monthly change value.
#
# 	desc = { text = x triggers = { } }	#default is <key>_desc, but you can do triggered overrides
# 	picture = GFX_evt_alien_nature 		#Also supports triggered pictures like in events
# 	category = positive/negative/neutral #Affects the tone of various UI elements
# }
#
# Situations can have up to two endings - one reached when progress reaches o (on_fail), the other when progress reaches its completion (on_progress_complete)
#
# 	complete_icon = GFX_icon			#Defines icon that will appear on the right side of the bar
# 	complete_icon_frame = GFX_icon_frame
# 	fail_icon = GFX_icon				#Defines icon that will appear on the left side of the bar
# 	fail_icon_frame = GFX_icon_frame
#
# 	custom_tooltip = LOC_KEY				# Replaces the Situation's own modifier description with the loc key.
# 	custom_tooltip_with_modifiers = LOC_KEY	# Prepends the loc key to the Situation's own modifier description.
# 	override_active_title = LOC_KEY			# Replaces the "Active Effects" panel title in the Situation Log.
# 	override_active_desc = LOC_KEY			# Replaces the whole "Active Effects" panel body in the Situation Log.
# 	override_finisher_title = LOC_KEY		# Replaces the "Finisher Effects" panel title in the Situation Log.
# 	override_finisher_desc = LOC_KEY		# Replaces the whole "Finisher Effects" panel body and hides its timer.
#
# 	on_start = { }						#Effects when the Situation is created
# 	on_progress_complete = {			#Effects when Situation's progress has reached its completion
# 										#You should always call destroy_situation = this from here or from an event fired by here
# 	}
# 	on_fail = {							#Effects when Situation's total progress is below 0
# 										#You should always call destroy_situation = this from here or from an event fired by here
# 	}
# 	on_abort = {}						#Effects when Situation is cancelled via abort_trigger trigger
# 	abort_trigger = {} 					#Trigger for when a Situation should abort, firing on_abort
# 	potential = {} 						#Trigger (scope: country) to check if a country can support a situation before creating it
#										#The situation will be removed if potential stops being true, without firing on_abort
#
# 	permanent = yes/no					#Default: no. If yes, the situation does not end automatically when it reaches either extreme
#										#It needs to be finished manually if needed
#
# 	show_in_outliner = yes/no			#Default: yes. If no, the situation will not appear in the Outliner situations group
#
# Situations can have modifiers. They will be applied as long as the Situation is active.
#
# 	modifier = { } 						#Modifier applying to the country experiencing the situation
# 	triggered_modifier = {				#Triggered modifier applying to the country experiencing the situation, if the triggers are true
# 		potential = { }					#The triggers to check for the modifier to be applied
# 		modifier = { }					#The modifier being applied (see modifiers.log for a complete list)
# 	}
#
# 	target_modifier = { } 				#Modifier applying to the target colony carrier of a Situation. Does not work on other scope types!
# 	triggered_target_modifier = {		#Modifier applying to the target colony carrier of a Situation, if the triggers are true. Does not work on other scope types!
# 		potential = { }
# 		modifier = { }
# 	}
#
#   This is a scriptable alert for when a situation has been blocked and requires an action from the player. If a trigger passes for any situation it will display the alert.
#   There can be multiple descriptions for multiple situations at a time, everything will be displayed in the tooltip of the alert.
#   triggered_blocked_desc = {
#       trigger = {}
#       text = ""
#   }
#
#
# PROGRESS BAR
# -----------------------
# Each Situation has a progress bar ranging from 1 to the completion value (generated by the end of the final stage).
# Progress can start anywhere in the bar.
#
# 	start_value = 20					# This is the minimum value that the situation can have (so the progress is contained between `start_value` and the `end` of the last stage )
#	initial_progress = 50				# The value the situation progress is going to have when starting. Important for bidirectional situations.
										# if it is lower than start_value, it will be changed to start_value
# 	progress_direction = bidirectional	#monodirectional/bidirectional (defaults to monodirectional)
# 	complete_category = positive		#Only for progress_direction = bidirectional - only affects progress towards completetion (right)
# 	fail_category = negative			#Only for progress_direction = bidirectional - only affects progress towards fail (left)
#
# There are two ways to size the progress bar and its stages:
#
# 1) FIXED ENDS (default): each stage declares an absolute `end` value (see stages, below). The bar's completion value is
#    the `end` of the final stage. This is the simplest approach when the boundaries never change.
#
# 2) SECTION WEIGHTS: declare `total_progress` on the Situation, and give each stage a `section_weight` instead of an `end`.
#    The total length of the bar is `total_progress`, and each stage occupies a slice proportional to its weight relative to
#    the sum of all stage weights. Use this when the bar's length and/or stage proportions should scale with empire state.
#
# 	total_progress = 60000				# Scriptable value (scope: situation). Total length of the bar from start_value to completion.
#										# Setting this switches the Situation into SECTION WEIGHTS mode: every stage must then use
#										# `section_weight` and none may use `end` (the game logs an error if you mix the two).
#
#    When `total_progress` is set, the game auto-generates two country modifiers that adjust the EFFECTIVE total length:
#		<situation_key>_max_progress_add	# flat addition to total_progress
#		<situation_key>_max_progress_mult	# percentage multiplier (applied as total * (1 + mult))
#    Effective total = ( total_progress + _max_progress_add ) * ( 1 + _max_progress_mult ), clamped to a minimum of 1.
#    Provide loc keys "mod_<situation_key>_max_progress_add" and "mod_<situation_key>_max_progress_mult" (the latter usually
#    just references the former via "$mod_<situation_key>_max_progress_add$"), and optionally matching modifier icons named
#    "mod_<situation_key>_max_progress_add.dds" / "..._mult.dds" under gfx/interface/icons/modifiers/.
#
#    In SECTION WEIGHTS mode the stage boundaries are recalculated every month, so the bar (and where each stage starts/ends)
#    grows or shrinks dynamically as the section weights and the max-progress modifiers change.
#
# The progress bar is divided in one or more stages. Each stage can have different modifiers associated with it.
#
# stages = { 							#List all your stages here, in the correct order. You need at least one.
#
# 	sample_stage = { 					#Expects the key to be localised. You can also define <key>_desc and it will show on the tooltip, but this is optional.
# 		icon = GFX_asset_name
# 		background = GFX_asset_name
# 		color = color_key				# Optional. Color for UI elements associated with this stage.
#										# Can be:
#										# - A key from the named colors database (e.g. "red")
#										# - A numeric RGBA vector (e.g. { 255 100 0 255 } or { 1.0 0.3 0.0 1.0 })
#										# Defaults to SITUATION_STAGE_DEFAULT_COLOR
#
# 		end = 40						# Where the stage ends and a new one starts. Determines the end value of the Situation, if it is the final stage.
#										# Mutually exclusive with `section_weight` - use `end` only when `total_progress` is NOT set.
# 		section_weight = 25				# Use INSTEAD of `end` when the Situation declares `total_progress`. The stage's slice of the bar
#										# is (this weight / sum of all stage weights) * effective total. Scriptable value (scope: situation),
#										# so it can be a flat number or a weight block, e.g.:
#										#   section_weight = { base = 25 modifier = { owner? = { has_valid_civic = civic_shared_burden } factor = 2 } }
# 		on_first_enter = { }			#Effect for the first time this stage fires
# 		on_enter = { }					#Effect every time we enter this stage
# 		modifier/triggered_modifier/target_modifier/triggered_target_modifier = { } #as standard (applies only during this Stage)
# 		custom_tooltip = x 				#Replaces this Stage's modifier description with the loc key.
# 		custom_tooltip_with_modifiers = x 	#Prepends the loc key to this Stage's modifier description.
# 	}
# }
#
# Every month, progress ticks up or down based on factors defined in monthly_progress:
#
# monthly_progress = {
# 	base = 1							# default monthly progress
# 	modifier = { 						#Standard weight fields, you can do everything that common/script_values/00_script_values.txt tells you about
# 		add = 2
# 		desc = federation_acceptance_reduce_fleet 	#Do not forget to add loc tooltips (the game will scream at you otherwise)
# 		<triggers>
# 	}
# }
#
#
# APPROACHES
# -----------------------
# Situations approaches allow players to define how they're dealing with the ongoing situation.
# Approaches can have different triggers, upkeep costs and modifiers associated with them.
#
# approach = {
# 	name = approach_a 					#This is localised. If you add a loc key "approach_a_desc", it will also show, but this is optional.
# 	icon = GFX_asset_icon
# 	icon_background = GFX_asset_icon_background
# 	allow = { } 						#If this fails, the Approach is greyed out
# 	potential = { } 					#If this fails, the Approach is not shown
# 	on_select = { } 					#Effect when you pick the Approach.
# 	default = yes 						#Sets the Approach to be the Situation's default. This means that it will be picked when the Situation starts, and if the current
# 										#Approach is invalidated (fails potential or allow check). This won't happen while the Situation is locked, so events which demand
# 										#a choice of Approach can lock the situation (set_situation_locked) in immediate (or the Situation's on_start) and unlock them in after.
#	custom_tooltip = LOC_KEY				# Replaces this Approach's modifier description with the loc key.
#	custom_tooltip_with_modifiers = LOC_KEY	# Prepends the loc key to this Approach's modifier description.
#
# 	modifier/triggered_modifier/target_modifier/triggered_target_modifier = { } #as standard (applies only when this Approach is picked)
#
# 	resources = { 						#Resource table as standard
# 		category = situations
# 		cost = { }
# 		upkeep = { }
# 		produces = { }
# 	}
# 	ai_weight = { } 					#AI will pick the one with the highest weight
# }
#
#
# EVENTS
# -----------------------
# Situations have their own own_action used to set either random or recurring events.
#
# 	on_monthly = { #Note: technically, this is an on_action called test_situation. So don't call your situation "on_monthly_pulse"!
# 		events = {
# 	    }
# 		random_events = {
# 	    }
# 	}
#
#  IMPORTANT NOTE: events impacting the situations itself (by adding progress, for example) should have their effects set
#  in an immediate = {} block - lest the players leave them unopened, but unclicked to avoid their negative outcomes.
#  Effects in immediate = {} don't always appear correctly in tooltips, though! Test your events carefully and, if necessary
#  use tooltip = {} in event options to correctly generate the tooltip.
#
#
#  EXAMPLE
#  -----------------------
#  All scopes are this/root = situation. You can scope to owner for the country or target for the target.
#
#  test_situation = {					#For loc strings, you need to define "test_situation", "test_situation_type", and "test_situation_desc"
# 										#first is the name while the Situation exists iIt can use [Target.GetName] and so on),
# 										#The _type key is used in cases where the Situation does not exist yet,
# 										#specifically the start_situation effect's tooltip (stuff like [Target.GetName] will not work there.)
# 	desc = { text = x triggers = { } }	#default is <key>_desc, but you can do triggered overrides
# 	picture = GFX_evt_alien_nature 		#Also supports triggered pictures like in events
# 	category = positive/negative/neutral #Affects the tone of various UI elements
#
# 	# Endings
# 	complete_icon = GFX_icon			#Defines icon that will appear on the right side of the bar
# 	complete_icon_frame = GFX_icon_frame
# 	fail_icon = GFX_icon				#Defines icon that will appear on the left side of the bar
# 	fail_icon_frame = GFX_icon_frame
#
# 	custom_tooltip = LOC_KEY				# Replaces the Situation's own modifier description with the loc key.
# 	custom_tooltip_with_modifiers = LOC_KEY	# Prepends the loc key to the Situation's own modifier description.
# 	override_active_title = LOC_KEY			# Replaces the "Active Effects" panel title in the Situation Log.
# 	override_active_desc = LOC_KEY			# Replaces the whole "Active Effects" panel body in the Situation Log.
# 	override_finisher_title = LOC_KEY		# Replaces the "Finisher Effects" panel title in the Situation Log.
# 	override_finisher_desc = LOC_KEY		# Replaces the whole "Finisher Effects" panel body and hides its timer.
#
# 	on_start = { }						#Effects when the Situation is created
# 	on_progress_complete = {			#Effects when Situation's progress has reached completion
# 										#You should always call destroy_situation = this from here or from an event fired by here
# 	}
# 	on_fail = {							#Effects when Situation's total progress is below 0
# 										#You should always call destroy_situation = this from here or from an event fired by here
# 	}
# 	on_abort = {}						#Effects when Situation is cancelled via abort_trigger trigger
# 	abort_trigger = {} 					#Trigger for when a Situation should abort, firing on_abort
#
# 	# Modifiers
# 	modifier = { } 						#Modifier applying to the country experiencing the situation
# 	triggered_modifier = {				#Triggered modifier applying to the country experiencing the situation, if the triggers are true
# 		potential = { }
# 		modifier = { }
# 	}
#
# 	target_modifier = { } 				#Modifier applying to the target colony carrier of a Situation. Does not work on other scope types!
# 	triggered_target_modifier = {		#Modifier applying to the target colony carrier of a Situation, if the triggers are true. Does not work on other scope types!
# 		potential = { }
# 		modifier = { }
# 	}
#
# 	#Progress
# 	start_value = 20					#Situation will start at this number. Default is 0
# 	progress_direction = bidirectional	#monodirectional/bidirectional (defaults to monodirectional)
# 	complete_category = positive		#Only for progress_direction = bidirectional - only affects progress towards completetion (right)
# 	fail_category = negative			#Only for progress_direction = bidirectional - only affects progress towards fail (left)
#
# 	stages = { 							#List all your stages here, in the correct order.
#
# 		sample_stage = { 					#Expects the key to be localised. You can also define <key>_desc and it will show on the tooltip, but this is optional.
# 			icon = GFX_asset_name
# 			background = GFX_asset_name
# 			color = "red"
# 			end = 40						# Where the stage ends and a new one starts. Determines the end value of the Situation, if it is the final stage.
# 			on_first_enter = { }			#Effect for the first time this stage fires
# 			modifier/triggered_modifier/target_modifier/triggered_target_modifier = { } #as standard (applies only during this Stage)
# 			custom_tooltip = x 				#this will print in the stage tooltip (on_first_enter will not, because spoilers; modifiers will)
# 		}
# 	}
#
# 	monthly_progress = {
# 		base = 1							# default monthly progress
# 		modifier = { 						#Standard weight fields, you can do everything that common/script_values/00_script_values.txt tells you about
# 			add = 2
# 			desc = federation_acceptance_reduce_fleet 	#Do not forget to add loc tooltips (the game will scream at you otherwise)
# 			<triggers>
# 		}
# 	}
#
# 	#Approaches
# 	approach = {
# 		name = approach_a 					#This is localised. If you add a loc key "approach_a_desc", it will also show, but this is optional.
# 		icon = GFX_asset_icon
# 		icon_background = GFX_asset_icon_background
# 		allow = { } 						#If this fails, the Approach is greyed out
# 		potential = { } 					#If this fails, the Approach is not shown
# 		on_select = { } 					#Effect when you pick the Approach.
#
# 		default = yes 						#Sets the Approach to be the Situation's default. This means that it will be picked when the Situation starts, and if the current
# 											#Approach is invalidated (fails potential or allow check). This won't happen while the Situation is locked, so events which demand
# 											#a choice of Approach can lock the situation (set_situation_locked) in immediate (or the Situation's on_start) and unlock them in after.
#
# 		modifier/triggered_modifier/target_modifier/triggered_target_modifier = { } #as standard (applies only when this Approach is picked)
#
# 		resources = { 						#Resource table as standard
# 			category = situations
# 			cost = { }
# 			upkeep = { }
# 			produces = { }
# 		}
# 		ai_weight = { } 					#AI will pick the one with the highest weight
# 	}
#
# 	# Events
# 	on_monthly = { #Note: technically, this is an on_action called test_situation. So don't call your situation "on_monthly_pulse"!
# 		events = {
# 		}
# 		random_events = {
# 		}
# 	}
#  }
