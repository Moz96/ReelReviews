require 'openai'

def ai_select_category(google_place_type, place_name)
  open_ai_client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])

  open_ai_user_message =  'You are given two pieces of information: ' +
                          'A single place type sent from the google places api, and the name of the place. ' +
                          'Please use both pieces of information to output the closest matching category from this list: ' +
                          'Culture, Bars, Outdoors, Cafés, Fitness.' +
                          'You only ever output a single category and no other text.'

  open_ai_response = open_ai_client.chat(
    parameters: {
      model: 'gpt-4',
      messages: [{ role: 'user', content: open_ai_user_message +
                                          "Google Place type: #{google_place_type}" +
                                          "Place name: #{place_name}"}],
      temperature: 1
    }
  )

  open_ai_response.dig("choices", 0, "message", "content")
end
