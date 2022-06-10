'use strict';

// image width.
const imgW = 400;

// Gallery using bricks.js ////////////////////////////////////////////////////

// mq      - the minimum viewport width (String CSS unit: em, px, rem)
// columns - the number of vertical columns
// gutter  - the space (in px) between the columns and grid items
const sizes = [
    { columns: 1, gutter: 30 },
    { mq: Math.round((imgW * 2.2) + 40) + "px", columns: 2, gutter: 35 },
    { mq: Math.round((imgW * 3.5) + 50) + "px", columns: 3, gutter: 50 },
    { mq: Math.round((imgW * 4.4) + 50) + "px", columns: 4, gutter: 50 },
];

const instance = Bricks({
    container: '#gallery',
    packed: 'data-packed',
    sizes: sizes
});

instance
    .on('pack',   () => console.log('ALL grid items packed.'))
    .on('update', () => console.log('NEW grid items packed.'))
    .on('resize', size => console.log('The grid has be re-packed to accommodate a new BREAKPOINT.', size));

// start it up, when the DOM is ready. note that if images are in the
// grid, you may need to wait for document.readyState === 'complete'.
document.addEventListener('DOMContentLoaded', event => {
    instance.resize(true).pack(); // bind resize handler & pack initial items
});
document.addEventListener('readystatechange', event => {
    if (event.target.readyState === 'complete') {
        instance.pack();
    }
});

// Re-packing after loading images ////////////////////////////////////////////

function onImagesLoaded(container, event) {
    let images = container.getElementsByTagName("img");
    let loaded = images.length;
    for (let i = 0; i < images.length; i++) {
        if (images[i].complete) {
            loaded--;
        }
        else {
            images[i].addEventListener("load", function () {
                loaded--;
                if (loaded == 0) {
                    event();
                }
            });
        }
        if (loaded == 0) {
            event();
        }
    }
}

const container = document.getElementById("gallery");
onImagesLoaded(container, function () {
    instance.pack();
});
