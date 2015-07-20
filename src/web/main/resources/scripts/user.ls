prelude = require 'prelude-ls'

window.STATUSTIMELINE = {}
	..set-event = ($status) ->
		function check-favorited
			($status.attr \data-is-favorited) == \true
		
		function check-reposted
			($status.attr \data-is-reposted) == \true
		
		$status
			# Set display talk window event 
			..find '.main .icon-anchor' .click ->
				window-id = "misskey-window-talk-#{$status.attr \data-user-id}"
				url = $status.find '.main .icon-anchor' .attr \href
				$content = $ '<iframe>' .attr {src: url, +seamless}
				window.open-window do
					window-id
					$content
					"<i class=\"fa fa-comments\"></i>#{$status.find \.user-name .text!}"
					300px
					450px
					yes
					url
				false

			# Ajax setting of reply-form
			..find \.reply-form .submit (event) ->
				event.prevent-default!
				$form = $ @
				$submit-button = $form.find \.submit-button
					..attr \disabled on
				$.ajax "#{config.api-url}/web/status/reply.plain" {
					type: \post
					data: new FormData $form.0
					-processData
					-contentType
					data-type: \text
					xhr-fields: {+with-credentials}}
				.done (html) ->
					$reply = $ html
					$submit-button.attr \disabled off
					$reply.append-to $status.find '.replies > .statuses'
					$i = $ '<i class="fa fa-ellipsis-v reply-info" style="display: none;"></i>'
					$i.append-to $status.find '.article-main'
					$form.remove!
					window.display-message '返信しました！'
				.fail ->
					$submit-button.attr \disabled off

			# Preview attache image
			..find '.image-attacher input[name=image]' .change ->
				$input = $ @
				file = $input.prop \files .0
				if file.type.match 'image.*'
					reader = new FileReader!
						..onload = ->
							$img = $ '<img>' .attr \src reader.result
							$input.parent '.image-attacher' .find 'p, img' .remove!
							$input.parent '.image-attacher' .append $img
						..readAsDataURL file

			## Init tag input of reply-form
			#..find '.reply-form .tag'
			#	.tagit {placeholder-text: 'タグ', field-name: 'tags[]'}
			
			# Init favorite button
			..find 'article > .article-main > .main > .footer > .actions > .favorite > .favorite-button' .click ->
				$button = $ @
					..attr \disabled on
				if check-favorited!
					$status.attr \data-is-favorited \false
					$.ajax "#{config.api-url}/status/unfavorite" {
						type: \delete
						data: {'status-id': $status.attr \data-id}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done ->
						$button.attr \disabled off
					.fail ->
						$button.attr \disabled off
						$status.attr \data-is-favorited \true
				else
					$status.attr \data-is-favorited \true
					$.ajax "#{config.api-url}/status/favorite" {
						type: \post
						data: {'status-id': $status.attr \data-id}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done ->
						$button.attr \disabled off
					.fail ->
						$button.attr \disabled off
						$status.attr \data-is-favorited \false
			
			# Init repost button
			..find 'article > .article-main > .main > .footer > .actions > .repost > .repost-button' .click ->
				$button = $ @
					..attr \disabled on
				if check-reposted!
					$status.attr \data-is-reposted \false
					$.ajax "#{config.api-url}/status/unrepost" {
						type: \delete
						data: {'status-id': $status.attr \data-id}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done ->
						$button.attr \disabled off
					.fail ->
						$button.attr \disabled off
						$status.attr \data-is-reposted \true
				else
					$status.attr \data-is-reposted \true
					$.ajax "#{config.api-url}/status/repost" {
						type: \post
						data: {'status-id': $status.attr \data-id}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done ->
						$button.attr \disabled off
					.fail ->
						$button.attr \disabled off
						$status.attr \data-is-reposted \false
			
			# Click event
			..click (event) ->
				$clicked-status = $ @
				
				can-event = ! (((<[ input textarea button i time a ]>
					|> prelude.map (element) -> $ event.target .is element)
					.index-of yes) >= 0)
				
				if document.get-selection!.to-string! != ''
					can-event = no
					
				if can-event
					animation-speed = 200ms
					if ($clicked-status.attr \data-display-html-is-active) == \false
						reply-form-text = $clicked-status.find 'article > .article-main > footer .reply-form textarea' .val!
						$ '.timeline > .statuses > .status > .status.article' .each ->
							$ @
								..attr \data-display-html-is-active \false
								..remove-class \display-html-active-status-prev
								..remove-class \display-html-active-status-next
						$ '.timeline > .statuses > .status > .status.article > article > .article-main > .talk > i' .each ->
							$ @ .show animation-speed
						$ '.timeline > .statuses > .status > .status.article > article > .article-main > .reply-info' .each ->
							$ @ .show animation-speed
						$ '.timeline > .statuses > .status > .status.article > article > .article-main > .talk > .statuses' .each ->
							$ @ .hide animation-speed
						$ '.timeline > .statuses > .status > .status.article > article > .article-main > footer' .each ->
							$ @ .hide animation-speed
						$clicked-status
							..attr \data-display-html-is-active \true
							..parent!.prev!.find '.status.article' .add-class \display-html-active-status-prev
							..parent!.next!.find '.status.article' .add-class \display-html-active-status-next
							..find 'article > .article-main > .talk > i' .hide animation-speed
							..find 'article > .article-main > .talk > .statuses' .show animation-speed
							..find 'article > .article-main > .reply-info' .hide animation-speed
							..find 'article > .article-main > footer' .show animation-speed
							..find 'article > .article-main > footer .reply-form textarea' .val ''
							..find 'article > .article-main > footer .reply-form textarea' .focus! .val reply-form-text
					else
						$clicked-status
							..attr \data-display-html-is-active \false
							..parent!.prev!.find '.status.article' .remove-class \display-html-active-status-prev
							..parent!.next!.find '.status.article' .remove-class \display-html-active-status-next
							..find 'article > .article-main > .talk > i' .show animation-speed
							..find 'article > .article-main > .talk > .statuses' .hide animation-speed
							..find 'article > .article-main > .reply-info' .show animation-speed
							..find 'article > .article-main > footer' .hide animation-speed


$ ->
	is-me = $ \html .attr \data-is-me
	
	# init icon edit form
	if is-me
		$form = $ \#icon-edit-form
		$submit-button = $form.find '[type=submit]'
		
		$ \#icon .click ->
			$ \#icon-edit-form-back .css \display \block
			$ \#icon-edit-form-back .animate {
				opacity: 1
			} 500ms \linear
			$ \#icon-edit-form .animate {
				top: 0
				opacity: 1
			} 1000ms \easeOutElastic
		
		$form.find \.cancel (event) ->
			event.prevent-default!
			$ \#icon-edit-form-back .animate {
				opacity: 0
			} 500ms \linear ->
				$ \#icon-edit-form-back .css \display \none
			$ \#icon-edit-form .animate {
				top: 0
				opacity: 1
			} 1000ms \easeInOutQuart
		
		$form.submit (event) ->
			event.prevent-default!
			$submit-button.attr \disabled yes
			$submit-button.attr \value '更新しています...'
			$.ajax config.api-url + '/account/update-icon' {
				+async
				type: \put
				-process-data
				-content-type
				data: new FormData $form.0
				data-type: \json
				xhr-fields: {+with-credentials}
				xhr: ->
					XHR = $.ajax-settings.xhr!
					if XHR.upload
						XHR.upload.add-event-listener \progress (e) ->
							percentage = Math.floor (parse-int e.loaded / e.total * 10000) / 100
							$form.find \progress
								..attr \max e.total
								..attr \value e.loaded
							$form.find '.progress .status' .text "アップロードしています... #{percentage}%"
						, false
					XHR
			}
			.done (data) ->
				location.reload!
			.fail (data) ->
				$submit-button.attr \disabled no
				$submit-button.attr \value '更新 \uf1d8'

		$form.find 'input[name=image]' .change ->
			$input = $ @
			file = $input.prop \files .0
			if file.type.match 'image.*'
				reader = new FileReader!
					..onload = ->
						$submit-button.attr \disabled no
						$ '#icon-edit-form .preview > .image' .attr \src reader.result
						$ '#icon-edit-form .preview > .image' .cropper {
							aspect-ratio: 1 / 1
							crop: (data) ->
								$ '#icon-edit-form input[name=trim-x]' .val Math.round data.x
								$ '#icon-edit-form input[name=trim-y]' .val Math.round data.y
								$ '#icon-edit-form input[name=trim-w]' .val Math.round data.width
								$ '#icon-edit-form input[name=trim-h]' .val Math.round data.height
						}
					..readAsDataURL file

	$ '#timeline .statuses .status .status.article' .each ->
		window.STATUSTIMELINE.set-event $ @
	
	function check-follow
		($ \html .attr \data-is-following) == \true
		
	if is-me
		$ \#name .click ->
			$ 'main > header' .attr \data-name-editing \true
	
	$ \#screen-name .click ->
		element= document.get-element-by-id \screen-name
		rng = document.create-range!
		rng.select-node-contents element
		window.get-selection!.add-range rng
	
	$ '#follow-button' .click ->
		$button = $ @
			..attr \disabled on
		if check-follow!
			$.ajax "#{config.api-url}/users/unfollow" {
				type: \delete
				data: {'user-id': $ \html .attr \data-user-id}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done ->
				$button
					..attr \disabled off
					..remove-class \following
					..add-class \notFollowing
					..text 'フォロー'
				$ \html .attr \data-is-following \false
			.fail ->
				$button.attr \disabled off
		else
			$.ajax "#{config.api-url}/users/follow" {
				type: \post
				data: {'user-id': $ \html .attr \data-user-id}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done ->
				$button
					..attr \disabled off
					..remove-class \notFollowing
					..add-class \following
					..text 'フォロー中'
				$ \html .attr \data-is-following \false
			.fail ->
				$button.attr \disabled off
	
	$ window .scroll ->
		top = $ @ .scroll-top!
		height = parse-int($ \#header-data .css \height)
		pos = 50 - ((top / height) * 50)
		$ \#header-data .css \background-position "center #{pos}%"
