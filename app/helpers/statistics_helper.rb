module StatisticsHelper
  def indices_by_rating
    line_chart @current_city_indices.group(:score).count, height: '500px', width: '500px',
 library: {
      title: {text: 'Scores by Index', x: -20},
      yAxis: {
         allowDecimals: false,
         title: {
             text: 'Name'
         }
      },
      xAxis: {
         title: {
             text: 'Score'
         }
      }
    }
  end
end
