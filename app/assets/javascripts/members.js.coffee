# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('#member_joined').click ->
    $('#joined_member_fields').toggle()

$ ->
  $('#member_application_exists').click ->
    $('#application_date_field').toggle()

$ ->
  $('#member_membership_paused').click ->
    $('#membership_pause_note_field').toggle()

$ ->
  $('#check_all').click ->
    box.checked = $('#check_all')[0].checked for box in $('.check')


