class EventLog < ActiveRecord::Base

	belongs_to :owner, polymorphic: true

	# def entry(acts_on, event_type, details=nil)


	# def create(event, actor, act_on)
	def self.entry(owner, acts_on, event_type, details=nil, log_level=LOG_FINE)
		event = EventLog.new(
			owner_id: owner.id, 
			owner_type: owner.class.name,
			acts_on_id: acts_on.id,
			acts_on_type: acts_on.class.name,
			event_type: event_type,
			details: details,
			log_level: log_level
		)

		who = get_name( owner )
		did_what = get_owner_action( event )
		to_whom = get_name( acts_on )
		
		event.description = "#{who} #{did_what} #{to_whom}"
		event.save
	end


	def self.get_name(owner)
		who = "Unknown"
		case owner.class.name
			when User.name
				who = owner.name
			when Epicenter.name
				who = owner.name
		end

		return who
	end


	def self.get_owner_action(event)
		action = ""

		case event.event_type
		when FRUIT_TRANSFER
			amount = event.details['value']
			fruittype = event.details['fruittype'] || "frugter"
			action = "overførte #{amount} #{fruittype} til"

		when EPICENTER_STATUS_CHANGE
			from = event.details['from']
			to = event.details['to']
			action = "ændrede status fra #{from} til #{to} på"

		when NEW_MEMBERSHIP
			membership = event.details['membership']
			action = "er blevet #{membership} medlem af"

		when MEMBERSHIP_CHANGE
			from = event.details['from']
			to = event.details['to']
			action = "ændrede medlemsskab fra #{from} til #{to} i"

		when DELETE_MEMBERSHIP
			action = "har meldt sig ud af"
			
		end

		return action
	end

end
