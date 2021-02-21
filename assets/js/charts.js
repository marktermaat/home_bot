window.getColor = function (index, alpha) {
  switch (index) {
    case 0: return `rgba(67, 56, 202, ${alpha})`;
    case 1: return `rgba(219, 39, 119, ${alpha})`;
    case 2: return `rgba(52, 211, 153, ${alpha})`;
    case 3: return `rgba(252, 211, 77, ${alpha})`;
    case 4: return `rgba(217, 119, 6, ${alpha})`;
    default: return `rgba(67, 56, 202, ${alpha})`;
  }
}

window.chartOptions = function(title) {
  return {
    title: {
      display: true,
      text: title
    },
    responsive: true,
    animation: {
      duration: 200
    },
    scales: {
      yAxes: [{
        stacked: true,
        ticks: {
          beginAtZero: true,
        },
      }],
      xAxes: [{
        stacked: true,
        type: 'time',
        time: {
          displayFormats: {
            hour: 'H:mm'
          }
        },
        ticks: {
          autoSkip: true,
          maxTicksLimit: 12
        }
      }]
    },
  }
}