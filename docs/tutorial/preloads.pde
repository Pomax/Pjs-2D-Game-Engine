/**
 * override!
 * this disables the default "loop()" when using addScreen
 */
void addScreen(String name, Screen screen) {
  screenSet.put(name, screen);
  if (activeScreen == null) { activeScreen = screen; }
  else { SoundManager.stop(activeScreen); }
}

/* @pjs pauseOnBlur="true";
        font="fonts/acmesa.ttf";
        preload=" graphics/mute.gif,
                  graphics/unmute.gif,
                  
                  graphics/assorted/Block.gif,
                  graphics/assorted/Coin-block.gif,
                  graphics/assorted/Coin-block-exhausted.gif,
                  graphics/assorted/Dragon-coin.gif,
                  graphics/assorted/Flower.gif,
                  graphics/assorted/Flowerpower.gif,
                  graphics/assorted/Goal-back.gif,
                  graphics/assorted/Goal-front.gif,
                  graphics/assorted/Goal-slider.gif,
                  graphics/assorted/Key.gif,
                  graphics/assorted/Keyhole.gif,
                  graphics/assorted/Mushroom.gif,
                  graphics/assorted/Passthrough-block.gif,
                  graphics/assorted/Pipe-body.gif,
                  graphics/assorted/Pipe-head.gif,
                  graphics/assorted/Regular-coin.gif,
                  graphics/assorted/Sky-block.gif,
                  graphics/assorted/Special.gif,
                  graphics/assorted/Target.gif,
                  graphics/assorted/Teleporter.gif,

                  graphics/backgrounds/bush-01.gif,
                  graphics/backgrounds/bush-02.gif,
                  graphics/backgrounds/bush-03.gif,
                  graphics/backgrounds/bush-04.gif,
                  graphics/backgrounds/bush-05.gif,

                  graphics/backgrounds/cave-corner-left.gif,
                  graphics/backgrounds/cave-corner-right.gif,
                  graphics/backgrounds/cave-filler.gif,
                  graphics/backgrounds/cave-side-left.gif,
                  graphics/backgrounds/cave-side-right.gif,
                  graphics/backgrounds/cave-top.gif,

                  graphics/backgrounds/ground-corner-left.gif,
                  graphics/backgrounds/ground-corner-right.gif,
                  graphics/backgrounds/ground-filler.gif,
                  graphics/backgrounds/ground-side-left.gif,
                  graphics/backgrounds/ground-side-right.gif,
                  graphics/backgrounds/ground-slant.gif,
                  graphics/backgrounds/ground-top.gif,

                  graphics/backgrounds/bonus.gif,
                  graphics/backgrounds/nightsky_bg.gif,
                  graphics/backgrounds/nightsky_fg.gif,
                  graphics/backgrounds/sky.gif,
                  graphics/backgrounds/sky_2.gif,

                  graphics/decals/100.gif,
                  graphics/decals/200.gif,
                  graphics/decals/300.gif,
                  graphics/decals/400.gif,
                  graphics/decals/500.gif,
                  graphics/decals/1000.gif,

                  graphics/enemies/Banzai-bill.gif,
                  graphics/enemies/Boo-chasing.gif,
                  graphics/enemies/Boo-waiting.gif,
                  graphics/enemies/Coin-boo-transition.gif,
                  graphics/enemies/Dead-koopa.gif,
                  graphics/enemies/Muncher.gif,
                  graphics/enemies/Naked-koopa-walking.gif,
                  graphics/enemies/Red-koopa-flying.gif,
                  graphics/enemies/Red-koopa-standing.gif,
                  graphics/enemies/Red-koopa-walking.gif,

                  graphics/mario/big/Crouching-mario.gif,
                  graphics/mario/big/Jumping-mario.gif,
                  graphics/mario/big/Looking-mario.gif,
                  graphics/mario/big/Running-mario.gif,
                  graphics/mario/big/Spinning-mario.gif,
                  graphics/mario/big/Standing-mario.gif,

                  graphics/mario/fire/Crouching-mario.gif,
                  graphics/mario/fire/Jumping-mario.gif,
                  graphics/mario/fire/Looking-mario.gif,
                  graphics/mario/fire/Running-mario.gif,
                  graphics/mario/fire/Spinning-mario.gif,
                  graphics/mario/fire/Standing-mario.gif,

                  graphics/mario/small/Crouching-mario.gif,
                  graphics/mario/small/Dead-mario.gif,
                  graphics/mario/small/Jumping-mario.gif,
                  graphics/mario/small/Looking-mario.gif,
                  graphics/mario/small/Running-mario.gif,
                  graphics/mario/small/Spinning-mario.gif,
                  graphics/mario/small/Standing-mario.gif,
                  graphics/mario/small/Winner-mario.gif"; */