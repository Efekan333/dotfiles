// Concave corner piece: an R×R square in frame colour with a quarter circle cut out of it,
// so the inner edge of the frame looks rounded. Drawn for the top-left corner; rotate for the others
// (rotation pivots on the centre of a square, so it stays in place).
import QtQuick

Canvas {
    width: Theme.rounding
    height: Theme.rounding

    onPaint: {
        const r = width, ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = Theme.frame;
        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.lineTo(r, 0);
        ctx.arc(r, r, r, -Math.PI / 2, Math.PI, true);   // top → left, the long way round the hole's side
        ctx.closePath();
        ctx.fill();
    }
}
