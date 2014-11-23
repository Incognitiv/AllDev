$.ajax
	url: "data/data.json"
	dataType: "json"
	success: (data_file) ->
		$("#title").html(data_file.title)
		$("#random_text").html(data_file.random_text)
		$("#random_text_2").html(data_file.random_text_2)
		$("#random_text_3").html(data_file.random_text_3)
		$("#random_text_4").html(data_file.random_text_4)
		return