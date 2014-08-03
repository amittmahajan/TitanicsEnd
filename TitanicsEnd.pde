// Imports!
import heronarts.lx.*;
import heronarts.lx.model.*;
import heronarts.lx.ui.*;
import heronarts.lx.ui.control.*;
import ddf.minim.*;

// Useful constants
final static int SECONDS = 1000;
final static int MINUTES = 60*SECONDS;
final static int FEET = 12;
final static int INCHES = 1;
final static float METER = 39.37*INCHES;

final static String OPC_HOST = "127.0.0.1";
final static int OPC_PORT = 7890;

// Global engine objects
Model model;
LX lx;

void setup() {
  // Processing config
  size(800, 600, OPENGL);
  
  // LX engine instance
  lx = new LX(this, model = new Model());
  
  // Patterns
  final LXPattern[] patterns;
  lx.setPatterns(patterns = new LXPattern[] {
    new Warp(lx),
    new Periodicity(lx),
    new ParameterWave(lx),
    // ...add your new patterns here
  });
  for (LXPattern pattern : patterns) {
    pattern.setTransition(new MultiplyTransition(lx).setDuration(3000));
  }
  
  // OPC Output
  final OPCOutput output;
  lx.addOutput(output = new OPCOutput(lx, OPC_HOST, OPC_PORT));
  output.enabled.setValue(false);
  
  // UI layers
  lx.ui.addLayer(new UICameraLayer(lx.ui) {
      protected void beforeDraw() {
        hint(ENABLE_DEPTH_TEST);
      }
      protected void afterDraw() {
        hint(DISABLE_DEPTH_TEST);
      }
    }
    .setCenter(model.cx, model.cy, model.cz)
    .setRadius(18*FEET)
    .setTheta(PI/12)
    .setPhi(-PI/24)
    .addComponent(new UIPointCloud(lx).setPointWeight(2))
  );
  lx.ui.addLayer(new UIChannelControl(lx.ui, lx, 4, 4));
  lx.ui.addLayer(new UIOutputControl(lx.ui, output, 4, 332));
}

void draw() {
  // Wipe background, engine takes care of the rest
  background(#191919);
}

static class UIOutputControl extends UIWindow {
  public UIOutputControl(UI ui, LXOutput output, float x, float y) {
    super(ui, "OUTPUT (" + OPC_HOST + ":" + OPC_PORT + ")", x, y, UIChannelControl.DEFAULT_WIDTH, 72);
    float yPos = UIWindow.TITLE_LABEL_HEIGHT;
    new UIButton(4, yPos, width - 8, 20)
    .setParameter(output.enabled)
    .setActiveLabel("Enabled")
    .setInactiveLabel("Disabled")
    .addToContainer(this); 
    yPos += 24;
    new UISlider(4, yPos, width - 8, 20)
    .setParameter(output.brightness)
    .addToContainer(this);
  }
}
