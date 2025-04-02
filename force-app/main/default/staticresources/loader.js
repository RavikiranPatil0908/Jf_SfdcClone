if (document.getElementById('popDiv') && document.getElementById('backDiv') && document.getElementById('myImg')) {
    divpop = document.getElementById('popDiv');
    divback = document.getElementById('backDiv');
    img = document.getElementById('myImg');
    divback.style.display = 'block';
    divpop.style.display = 'block';
    img.style.display = 'block';
} else {
    // Create a background and show the image on top
    divpop = document.createElement('div');
    divpop.id = 'popDiv';
    divpop.style.backgroundColor = 'white';
    divpop.style.borderWidth = '0px';
    divpop.style.borderRadius = '5px';
    divpop.style.zIndex = '9998';
    divpop.style.left = '50%';
    divpop.style.top = '50%';
    divpop.style.width = '115px';
    divpop.style.height = '50px';
    divpop.style.position = 'fixed';
    divpop.style.marginLeft = '-25px';
    divpop.style.marginTop = '-25px';
    document.body.appendChild(divpop);

    img = document.createElement('img');
    img.id = 'myImg';
    img.src = '/img/loading24.gif'; // your spinner gif
    img.style.top = '50%';
    img.style.position = 'fixed';
    img.style.zIndex= '9999';
    img.style.left = '50%';
    img.style.marginLeft = '-12px';
    img.style.marginTop = '-12px';

    var div1 = document.createElement('div');
    div1.id = 'msgDiv';
    div1.style.float = 'right';
    div1.style.marginTop = '18px';
    div1.style.marginRight = '15px';
    div1.style.fontSize = '12px';
    div1.style.fontWeight = '700';
    div1.innerHTML = 'Loading…';

    /* Append loading gif image in parent div */
    divpop.appendChild(img);

    /* Append message div in parent div */
    divpop.appendChild(div1);

    divback = document.createElement('div');
    divback.id = 'backDiv';
    divback.style.backgroundColor = 'black';
    divback.style.opacity = '0.60';
    divback.style.filter = 'alpha(opacity = 30)';
    divback.style.position = 'fixed';
    divback.style.width = '100%';
    divback.style.height = '100%';
    divback.style.top = '0';
    divback.style.left = '0';
    divback.style.zIndex = '9997';
    document.body.appendChild(divback);
}