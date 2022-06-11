'use strict';

const round = Math.round;

// image width.
const imgW = 400;

// Gallery using bricks.js ////////////////////////////////////////////////////

const sizes = [
    { columns: 1, gutter: 30 },
    { mq: round((imgW * 2.2) + 40) + "px", columns: 2, gutter: 35 },
    { mq: round((imgW * 3.5) + 50) + "px", columns: 3, gutter: 50 },
    { mq: round((imgW * 4.4) + 50) + "px", columns: 4, gutter: 50 },
];

const bricks = Bricks({
    container: '#gallery',
    packed: 'data-packed',
    sizes: sizes
});

bricks
    .on('pack',   () => console.log('ALL grid items packed.'))
    .on('update', () => console.log('NEW grid items packed.'))
    .on('resize', size => console.log(
        'The grid has be re-packed to accommodate a new BREAKPOINT.', size
    ));

document.addEventListener('DOMContentLoaded', event => {
    bricks.resize(true); // bind resize handler
});

// Packing after loading images ////////////////////////////////////////////

const onImagesLoaded = (container, event) => {
    const images = container.getElementsByTagName("img");
    const progressBar = document.getElementById("loading-progress");

    // failed keeps track of images that failed to load.
    let failed = 0;
    let remaining = images.length;

    for (let i = 0; i < images.length; i++) {
        if (images[i].complete)
            remaining--;
        else {
            // Add listeners to images that have to be loaded.
            images[i].addEventListener("load", function () {
                remaining--;
                progressBar.value = round(
                    ((images.length - remaining) / images.length) * 100
                );
                if (remaining === failed)
                    event(remaining, failed, progressBar);
            });

            // If loading fails then we increment failed, an error
            // will be shown later.
            images[i].addEventListener("error", function () {
                failed++;
                if (remaining === failed)
                    event(remaining, failed, progressBar);
            });

        }
        if (remaining == failed)
            event(remaining, failed, progressBar);
    }
};

const gallery = document.getElementById("gallery");
const imagesLoaded = (remaining, failed, progressBar) => {
    bricks.pack();

    progressBar.value = 100;
    document.getElementById("loading").style.display = "none";

    // Show error on failure.
    const loadError = document.getElementById("loading-error");
    const loadErrorText = document.getElementById("loading-error-text");
    const loadErrorDismiss = document.getElementById("loading-error-dismiss");
    if (failed !== 0) {
        loadError.style.display = "block";
        const t = failed === 1 ? "image" : "images";
        loadErrorText.innerHTML = `${failed} ${t} failed to load.`;

        loadErrorDismiss.addEventListener('click', function(){
            loadError.style.display = "none";
        });
    }
};

onImagesLoaded(gallery, imagesLoaded);
