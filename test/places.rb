@client = GooglePlaces::Client.new(ENV['GOOGLE_PLACES_API'])
results = @client.predictions_by_input(
      'London',
      types: 'geocode',
      language: I18n.locale,
)

puts results.first.description
