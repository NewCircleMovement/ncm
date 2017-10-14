class EventLog < ActiveRecord::Base

	# def create(event, actor, act_on)
	def self.new_entry(actor, acts_on, event_type, details)
		event = EventLog.new(
			actor_id: actor.id, 
			actor_type: actor.class.name,
			acts_on_id: acts_on.id,
			acts_on_type: acts_on.class.name,
			event_type: event_type,
			details: details
		)

		who = get_actor( actor )
		does_what = get_action( event )
		to_whom = get_actor( acts_on )
		event.description = "#{who} #{does_what} #{to_whom}"
		event.save
	end


	def self.get_actor(actor)
		who = "Unknown"
		case actor.class.name
			when User.name
				who = actor.name
			when Epicenter.name
				who = actor.name
		end

		return who
	end


	def self.get_action(event)

		action = ""

		case event.event_type
		when FRUIT_TRANSFER
			amount = event.details['value']
			fruittype = event.details['fruittype'] || "frugter"
			action = "overførte #{amount} #{fruittype} til"
		end

		return action
	end

end
