import fsm from './StateMachine.js';
import spriteCreator from './spriteCreator.js';

cc.Class({
    extends: cc.Component,

    properties: {
        playground: cc.Node,
        hero: cc.Node,
        firstLand: cc.Node,

        landRange: {visible: false, default: cc.v2(20,300)},
        landWidth: {visible: false, default: cc.v2(20,200)},
        currentLandRange: {visible: false, default: 0},
        runLength: {visible: false, default: 0},
        secondLand: {type: cc.Node, visible: false, default: null},
        stick: {type: cc.Node, visible: false, default: null},
        stickLengthen: {visible: false, default: false},
        stickWidth: {visible: false, default: 6},
        stickSpeed: {visible: false, default: 400},
        heroMoveSpeed: {visible: false, default: 400},
    },

    // use this for initialization
    onLoad() {
        fsm.gameDirector = this;
        if(fsm.state === 'end'){
            cc.log('state=' + fsm.state  + ' ' + fsm.transitions());
            fsm.restart();
        }
        cc.log(this.playground)
        this.registerEvent();

        this.createNewLand();
        var range = this.getLandRange();
        this.heroWorldPosX = this.firstLand.width - (1 - this.hero.anchorX) * this.hero.width - this.stickWidth;
        this.secondLand.setPosition(range + this.firstLand.width, 0);
        //cc.log("[" + this.secondLand.x, + this.secondLand.y, + this.secondLand.width, + this.secondLand.height + "]");
        //init hero animation callback.
        var ani = this.hero.getComponent(cc.Animation);
        ani.on('stop',(event)=>{
            if(event.target.name =='heroTick'){
                cc.log('state=' + fsm.state  + ' ' + fsm.transitions());
                fsm.stickFall();
            }
        });
    },

    // called every frame, uncomment this function to activate update callback
    update(dt) {
        if (this.stickLengthen){
            //cc.log("[" + this.stick.x, + this.stick.y, + this.stick.width, + this.stick.height + "]");
            this.stick.height += dt * this.stickSpeed;
        }
    },

    registerEvent(){
        this.node.on(cc.Node.EventType.TOUCH_START, this.touchStart.bind(this), this.node);
        this.node.on(cc.Node.EventType.TOUCH_END,this.touchEnd.bind(this), this.node);
        this.node.on(cc.Node.EventType.TOUCH_CANCEL,this.touchCancel.bind(this), this.node);
        console.log("on");
    },
    unregisterEvent(){
        this.node.targetOff(this.node);
        console.log("off");
    },

    touchStart(event){
        cc.log("touchStart");
        cc.log('state=' + fsm.state  + ' ' + fsm.transitions());
        fsm.stickLengthen();
        cc.log("touchStart");
    },
    touchEnd(event){
        cc.log("touchEnd");
        cc.log('state=' + fsm.state  + ' ' + fsm.transitions());
        fsm.heroTick();
        cc.log("touchEnd");
    },
    touchCancel(){
        this.touchEnd();
        cc.log("touchCancel");
    },

    createStick(){
        cc.log("createStick");
        var stick = spriteCreator.createStick(this.stickWidth);
        stick.parent = this.playground;
        return stick
    },
    heroMove(target, length, callFunc=null){
        var time  = length / this.heroMoveSpeed;
        var heroMove = cc.moveBy(time, cc.p(length, 0));
        if(callFunc){
            var se = cc.sequence(heroMove, callFunc);
            this.hero.runAction(se);
        }else{
            this.hero.runAction(heroMove);
        }
    },
    stickAndHeroDownAction(callFunc){
        //stick down action;
        var stickAction = cc.rotateBy(0.5, 90);
        stickAction.easing(cc.easeIn(3));
        this.stick.runAction(stickAction);

        //hero down action;
        var heroAction = cc.moveBy(0.5,cc.p(0,-300 - this.hero.height));
        heroAction.easing(cc.easeIn(3));
        var seq =cc.sequence(heroAction,callFunc);
        this.hero.runAction(seq);
    },

    restart(){
        cc.log('state=' + fsm.state  + ' ' + fsm.transitions());
        fsm.restart();
    },

    createNewLand() {
        this.secondLand = spriteCreator.createNewLand(this.getLandWidth());
        this.secondLand.parent = this.playground;
    },

    landCreateAndMove(callFunc) {
        var winSize = cc.director.getWinSize();

        //firstland;
        var length = this.currentLandRange + this.secondLand.width;

        this.runLength += length;
        var action = cc.moveBy(0.5 ,cc.p(-length,0));
        this.playground.runAction(action);
        this.firstLand = this.secondLand;

        this.createNewLand();

        //landRange
        var range = this.getLandRange();

        //secondland;
        this.secondLand.setPosition(this.runLength + winSize.width,0);
        cc.log("[" + this.secondLand.x, + this.secondLand.y, + this.secondLand.width, + this.secondLand.height + "]");
        var l = winSize.width - range - this.heroWorldPosX - this.hero.width * this.hero.anchorX - this.stickWidth;
        var secondAction = cc.moveBy(this.moveDuration,cc.p(-l,0));
        var seq =cc.sequence(secondAction,callFunc);
        this.secondLand.runAction(seq);
    },

    getLandRange(){
        this.currentLandRange = this.landRange.x +(this.landRange.y - this.landRange.x)*Math.random();
        var winSize = cc.director.getWinSize();
        if(winSize.width < this.currentLandRange + this.heroWorldPosX + this.hero.width + this.secondLand.width){
            this.currentLandRange = winSize.width - this.heroWorldPosX - this.hero.width - this.secondLand.width;
        }
        return this.currentLandRange;
    },
    getLandWidth(){
        return this.landWidth.x + (this.landWidth.y - this.landWidth.x) * Math.random();
    }
});
