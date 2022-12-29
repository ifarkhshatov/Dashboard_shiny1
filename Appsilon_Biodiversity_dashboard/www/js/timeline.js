var video = document.getElementById("myVideo");
var btn = document.getElementById("myBtn");

function myFunction() {
  // open first page of dashboard
  $('.nav-tabs li a')[1].click()
}

Shiny.addCustomMessageHandler("addFilters", function (data) {
    if(data[0] === "click") {
    $("#addFilters").slideToggle()
   }
})

// $(document).ready(function() {
//             $("#addFilters").slideToggle()
        
// });
    
var timelineChartData
Shiny.addCustomMessageHandler("timelineChart", function (data) {
    timelineChartData = data;
    createChart(".timeline", data);
})


function createChart(className, data) {
    $(className).empty();
    $(className).append(
        '<canvas id="chart-timeline"></canvas>'
    );
    var ctx = document.getElementById("chart-timeline")//.getContext('2d');

    const totalDuration = 3000;
    const delayBetweenPoints = totalDuration / data.length;
    const previousY = (ctx) => ctx.index === 0 ? ctx.chart.scales.y.getPixelForValue(100) : ctx.chart.getDatasetMeta(ctx.datasetIndex).data[ctx.index - 1].getProps(['y'], true).y;
    var animation = {
      x: {
        type: 'number',
        easing: 'linear',
        duration: delayBetweenPoints,
        from: NaN, // the point is initially skipped
        delay(ctx) {
          if (ctx.type !== 'data' || ctx.xStarted) {
            return 0;
          }
          ctx.xStarted = true;
          return ctx.index * delayBetweenPoints;
        }
      },
      y: {
        type: 'number',
        easing: 'linear',
        duration: delayBetweenPoints,
        from: previousY,
        delay(ctx) {
          if (ctx.type !== 'data' || ctx.yStarted) {
            return 0;
          }
          ctx.yStarted = true;
          return ctx.index * delayBetweenPoints;
        }
      }
    };

    if (data.length < 15) {
        animation = {}
    }

    console.log(data.length)

  new Chart(ctx, {
    type: 'line',
    data: {
        labels: data.map(x=>x.labels),
        datasets: [{
        label: 'Data',
        fill: true,
        backgroundColor: 'rgba(54, 73, 53, 0.9)',
        borderColor: 'rgb(54, 73, 53)',
        // lineTension: 0.5,
        data: data.map(x=>x.data)
        }]
    },
    options: {
        animation,
        interaction: {
          intersect: false
        },
        plugins : {
            legend: {
                display: false,
             },
             title:{
                display: true,
                text: 'Species Timeline Distribution by Year of Fidings',
                fontSize: 14,
             },
             tooltips: {
                enabled: false,
             },
        } ,
    maintainAspectRatio: false,
    scales: {
        y: {
          ticks: {
            beginAtZero: true
          },
        },
        x: {  
          grid: {
            display: false,//SHOW_GRID,
            type: 'linear'
          }
        }
      }
    }
    });
}


