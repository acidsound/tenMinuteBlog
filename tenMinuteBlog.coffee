# make Posts into global variable
@Posts = new Meteor.Collection 'Posts'
# when client
if Meteor.is_client
	getDateStringFromTime = (regist, isISO) ->
		((t) ->
			realHour = 0
			if t.hour is 0
				realHour = 12
			else if t.hour > 12
				realHour = t.hour - 12
			else
				realHour = t.hour
			realHour + ":" + t.minute + " " + t.ampm + ", " + (if t.d < 10 then "0" else "") + t.d + "/" + (if t.m < 10 then "0" else "") + t.m + "/" + t.y
		) ((time) ->
			hour: time.getHours()
			minute: time.getMinutes()
			ampm: (if time.getHours() < 12 then "AM" else "PM")
			d: time.getDate()
			m: (time.getMonth() + 1)
			y: time.getFullYear()
		)(new Date(regist))
	niceTime = (unixTime) ->
		lengths = [ 60, 60, 24, 7, 4.35, 12, 10 ]
		now = Date.now()
		difference = (now - unixTime)/1000
		j=0
		while difference >= lengths[j] and j < lengths.length - 1
			difference /= lengths[j]
			j++
		difference = Math.round(difference)
		if j > 4 then getDateStringFromTime new Date(unixTime), true else "#{difference} #{['second','minute','hour','day','week','month','year'][j]} ago"
	$.extend Template.add,
		events:
			'click #add': ->
				Posts.insert
					subject: $('#subject').val()
					context: $('#context').val()
					createdTimestamp: Date.now()
				$('#subject').val('')
				$('#context').val('')
	$.extend Template.list,
		posts: ->
			result = (Posts.find {}, sort:createdTimestamp:-1, limit:10).map (v)-> $.extend v, createDate:niceTime(v.createdTimestamp)

if Meteor.is_server
  Meteor.startup -> console.log 'started'
