import Float "mo:base/Float";
import Int "mo:base/Int";
import Option "mo:base/Option";

module Calculator {
    //=============== CALCULATOR FUNCTIONS ===============\\
    public func add(counter : Float, val : Float) : Float {
        return counter + val;
    };

    public func subtract(counter : Float, val : Float) : Float {
        return counter - val;
    };

    public func multiply(counter : Float, val : Float) : Float {
        return counter * val;
    };

    public func divide(counter : Float, val : Float) : ?Float {
        assert (val != 0);
        var result : ?Float = null;

        if (val != 0) {
            result := Option.make<Float>(Float.div(counter, val));
        };

        return result;
    };

    public func power(counter : Float, val : Float) : Float {
        return Float.pow(counter, val);
        // Invert for negative power.
        /*var invert = pow < 0;
        var pow = Float.abs(val);
        var result = counter;

        while (pow > 0) {
            result *= pow;
            pow -= 1;
        };

        if (invert) {
            // Invert for negative power.
            return 1 / result;
        } else {
            return result;
        };*/
    };

    public func sqrt(counter : Float) : Float {
        return Float.sqrt(counter);
    };

    public func floor(counter : Float) : Int {
        return convertFloatToInt(Float.floor(counter));
    };


    //=============== UTILITY FUNCTIONS ===============\\
    public func convertFloatToInt(x : Float) : Int {
        return Float.toInt (x);
    };
};
