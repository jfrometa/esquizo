// web/flutter_bootstrap.js
{{flutter_js}}
{{flutter_build_config}}

// Performance tracking
window.performance.mark('flutter-engine-init');

// Google Maps API with proper loading
let mapsLoaded = false;
window.initMapsWhenNeeded = function() {
  if (!mapsLoaded) {
    return new Promise((resolve) => {
      window.initMap = function() {
        mapsLoaded = true;
        resolve();
        console.log('Maps loaded correctly');
      };
      
      const script = document.createElement('script');
      script.src = "https://maps.googleapis.com/maps/api/js?key=AIzaSyAlk83WpDsAWqaa4RqI4mxa5IYPiuZldek&loading=async&callback=initMap";
      script.defer = true;
      document.head.appendChild(script);
    });
  }
  return Promise.resolve();
};

// Connection speed detection
const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
const isSlowConnection = connection && (connection.effectiveType === '2g' || connection.effectiveType === '3g');
window.slowConnection = isSlowConnection;

// Initialize Flutter with proper configuration
_flutter.loader.load({
  config: {
    // Use HTML renderer for faster initial load
    renderer: isSlowConnection ? 'html' : 'canvaskit',
  },
  onEntrypointLoaded: async function(engineInitializer) {
    // Update loading message
    const progressElement = document.getElementById('progress-message');
    if (progressElement) {
      progressElement.innerText = "Inicializando Applicación...";
    }
    
    window.performance.mark('flutter-engine-initializing');
    const appRunner = await engineInitializer.initializeEngine();
    
    window.performance.mark('flutter-engine-initialized');
    if (progressElement) {
      progressElement.innerText = "Ejecutando Kako...";
    }
    
    await appRunner.runApp();
    window.performance.mark('flutter-app-running');
    
    // Measure engine initialization time
    window.performance.measure('flutter-engine-init-time', 'flutter-engine-init', 'flutter-engine-initialized');
    console.log('Engine initialization time:', performance.getEntriesByName('flutter-engine-init-time')[0].duration.toFixed(2) + 'ms');
  }
});