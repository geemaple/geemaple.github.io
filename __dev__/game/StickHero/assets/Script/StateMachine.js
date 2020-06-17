import StateMachine from 'javascript-state-machine'
import StateMachineHistory from 'javascript-state-machine/lib/history';


export default new StateMachine({
    init: 'stand',
    data: {
        gameDirector:null,
    },
    transitions:[
        {name:'stickLengthen',from:'stand',to:'stickLengthened'},
        {name:'heroTick',from:'stickLengthened',to:'heroTicked'},
        {name:'stickFall',from:'heroTicked',to:'stickFalled'},
        {name:'heroMoveToLand',from:'stickFalled',to:'heroMovedToLand'},
        {name:'landMove',from:'heroMovedToLand',to:'stand'},
        {name:'heroMoveToStickEnd',from:'stickFalled',to:'heroMovedToStickEnd'},
        {name:'heroDown',from:'heroMovedToStickEnd',to:'heroDowned'},
        {name:'gameOver',from:'heroDowned',to:'end'},
        {name:'restart',from:'end',to:'stand'},
    ],
    methods:{
        onStickLengthen(){
            this.gameDirector.stickLengthen = true;
            this.gameDirector.stick = this.gameDirector.createStick();
            this.gameDirector.stick.x = this.gameDirector.hero.x + this.gameDirector.hero.width * (1-this.gameDirector.hero.anchorX) + this.gameDirector.stick.width * this.gameDirector.stick.anchorX;
            var ani = this.gameDirector.hero.getComponent(cc.Animation);
            ani.play('heroPush');
        },
        onHeroTick(){
            this.gameDirector.unregisterEvent();
            this.gameDirector.stickLengthen = false;
            var ani = this.gameDirector.hero.getComponent(cc.Animation);
            ani.play('heroTick');
        },
        onStickFall(){

            var stickFall = cc.rotateBy(0.5, 90);
            stickFall.easing(cc.easeIn(3));

            var callFunc = cc.callFunc(function(){
                var stickLength = this.gameDirector.stick.height - this.gameDirector.stick.width * this.gameDirector.stick.anchorX;

                if (stickLength < this.gameDirector.currentLandRange || stickLength > this.gameDirector.currentLandRange + this.gameDirector.secondLand.width) {
                    this.heroMoveToStickEnd();
                }else{
                    this.heroMoveToLand();
                    if(stickLength > this.gameDirector.currentLandRange + this.gameDirector.secondLand.width/2 - 5
                        && stickLength < this.gameDirector.currentLandRange + this.gameDirector.secondLand.width/2 + 5){
                        cc.log("perfect");
                    }
                }
            }.bind(this));

            var se = cc.sequence(stickFall, callFunc);
            this.gameDirector.stick.runAction(se);

            cc.log('onStickFall');
        },
        onHeroMoveToLand(){
            var ani = this.gameDirector.hero.getComponent(cc.Animation);
            var callFunc = cc.callFunc(function(){
                ani.stop('heroRun');
                this.landMove();
            }.bind(this));
            ani.play('heroRun');
            var moveLength = this.gameDirector.currentLandRange + this.gameDirector.secondLand.width;
            this.gameDirector.heroMove(this.gameDirector.hero, moveLength, callFunc);

            cc.log('onHeroMoveToLand');
        },
        onLandMove(){
            var callFunc = cc.callFunc(function(){
                this.gameDirector.registerEvent();
            }.bind(this));
            this.gameDirector.landCreateAndMove(callFunc);
            cc.log('onLandMove');
        },
        onHeroMoveToStickEnd(){
            var ani = this.gameDirector.hero.getComponent(cc.Animation);
            var callFunc = cc.callFunc(function(){
                ani.stop('heroRun');
                this.heroDown();
            }.bind(this));
            ani.play('heroRun');
            this.gameDirector.heroMove(this.gameDirector.hero, this.gameDirector.stick.height, callFunc);
            cc.log('onHeroMoveToStickEnd');
        },
        onHeroDown(){
            var callFunc = cc.callFunc(function(){
                this.gameOver();
            }.bind(this));
            this.gameDirector.stickAndHeroDownAction(callFunc);
            cc.log('onHeroDown');
        },
        onGameOver(){
            cc.director.loadScene('StartScene');
            cc.log('onGameOver');
        },
        onRestart(){
            cc.log('onRestart');
        }
    }
});
