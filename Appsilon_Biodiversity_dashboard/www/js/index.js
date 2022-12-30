// var video = document.getElementById("myVideo");
// var btn = document.getElementById("myBtn");
//close intro
function closeIntro(){
$('#introDiv').slideToggle();
Shiny.setInputValue('introDivClose',"go")
}
// start buttons
function clickFunctionStart(id) {
  var index; 
  if (id == "dashboardBtn") {
    index = 2
  } else {
    index = 1
  }
  // open first page of dashboard
  $('.nav-tabs li a')[index].click()
}
// imitation of slider from shiny.js 

Shiny.addCustomMessageHandler("addFilters", function (data) {
    if(data[0] === "click") {
    if ($("#search_by_name i").hasClass("fa-caret-up")) {

        $("#search_by_name i").removeClass("fa-caret-up").addClass('fa-caret-down')
    } else {
        $("#search_by_name i").removeClass("fa-caret-down").addClass('fa-caret-up')
    }
    $("#addFilters").slideToggle()
   }
})


//closing tab
Shiny.addCustomMessageHandler("closeThisTab", function (data) {
  $('.closeButtons').click(  function() {
    var dataValue = $(this).parent().parent()[0].getAttribute("data-value");
        Shiny.setInputValue('closeIdTab',   dataValue)
  });
  clickFunctionStart('dashboardBtn')

})


// return id of Map

function clickIdFunction(id) {
Shiny.setInputValue('idFromMapMarker',id)
}



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
                text: 'Species Timeline Distribution by Year',
                align: 'start',
                font: {
                    size: 16,
                    weight: 10
                }
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


