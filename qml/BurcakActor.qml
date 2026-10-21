import QtQuick
import "BurcakMoves.js" as Moves

// Bir hareketi oynatır: her karede pozu hesaplar, önceki pozdan yumuşak geçişle iskelete uygular.
Item {
    id: actor
    property string move: "nefes"
    property real bpm: 110
    property string outfit: "gunduz"
    property bool running: true
    property real fixedPhase: -1          // ≥0 ise sabit evre (önizleme)
    // Davranış katmanları (hareketin üstüne yazar)
    property string eyesOverride: ""
    property string mouthOverride: ""
    property bool blushOverride: false
    property real lean: 0
    signal finished(string name)

    readonly property var current: Moves.moves[move] || Moves.moves.nefes
    readonly property bool backView: current.view === "arka"
    width: 200; height: 260

    property real elapsed: 0
    property var fromPose: null
    property real blend: 1
    property bool done: false
    onMoveChanged: { fromPose = snapshot(); blend = 0; elapsed = 0; done = false; }

    readonly property var numeric: ["bob", "headTilt", "hairSway", "armLShoulder", "armLElbow", "armRShoulder", "armRElbow",
                                    "legL", "legR", "bodyTilt", "squashX", "squashY", "dx"]
    function snapshot() { const o = {}; for (const k of numeric) o[k] = front[k]; return o; }
    function apply(phase) {
        const p = current.pose(phase);
        if (backView) {
            for (const k of ["legL", "legR", "headTilt", "hairSway", "breathe", "reach"]) if (p[k] !== undefined) rear[k] = p[k];
            return;
        }
        const k2 = blend < 1 ? blend * blend * (3 - 2 * blend) : 1;
        for (const k of numeric) {
            const v = p[k];
            front[k] = fromPose && k2 < 1 ? fromPose[k] + (v - fromPose[k]) * k2 : v;
        }
        front.bodyTilt += lean;
        front.eyes = eyesOverride || p.eyes;
        front.mouth = mouthOverride || p.mouth;
        front.blush = blushOverride || p.blush;
        front.prop = p.prop;
        front.hand = p.hand;
    }
    FrameAnimation {
        running: actor.running && actor.fixedPhase < 0 && actor.visible
        onTriggered: {
            const dur = Moves.durationOf(actor.current, actor.bpm);
            actor.elapsed += frameTime * 1000;
            actor.blend = Math.min(1, actor.blend + frameTime / .25);
            let phase = actor.elapsed / dur;
            if (!actor.current.loop && phase >= 1) {
                phase = .999;
                if (!actor.done) { actor.done = true; actor.finished(actor.move); }
            }
            actor.apply(phase % 1);
        }
    }
    Component.onCompleted: { fromPose = null; blend = 1; apply(fixedPhase >= 0 ? fixedPhase : 0); }
    onFixedPhaseChanged: if (fixedPhase >= 0) { blend = 1; apply(fixedPhase); }

    BurcakFigure { id: front; visible: !actor.backView; outfit: actor.outfit }
    BurcakBack {
        id: rear; visible: actor.backView; outfit: actor.outfit
        x: (actor.width - width) / 2; y: actor.height - height
    }
}
