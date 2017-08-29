module StatisticsHelper
  def indices_by_rating
    bar_chart @indices.group(:score).count, height: '500px',
 library: {
      title: {text: 'Scores by Index', x: -20},
      yAxis: {
         allowDecimals: false,
         title: {
             text: 'Score Count'
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
