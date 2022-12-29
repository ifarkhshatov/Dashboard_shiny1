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
    new Chart(ctx, {
    type: 'line',
    data: {
        labels: data.map(x=>x.labels),
        datasets: [{
        label: 'Data',
        fill: true,
        backgroundColor: 'rgba(54, 73, 53, 0.2)',
        borderColor: 'rgb(54, 73, 53)',
        lineTension: 0.5,
        data: data.map(x=>x.data)
        }]
    },
    options: {
        plugins : {
            legend: {
                display: false,
             },
             tooltips: {
                enabled: false,
             },
        } ,
    maintainAspectRatio: false,
    scales: {
        yAxes: [{
          ticks: {
            beginAtZero: true
          },  
        }]
      }
    }
    });
}