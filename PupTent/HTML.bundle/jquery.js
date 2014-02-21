(function($) {
    $(document).ready(function() {
        $(".swipe").swipe({
            selected: "selected"
        });
        $("audio").audio();
    });
    
    $.fn.swipe = function(options) {
        if (typeof Swipe === "undefined") {
            var _this = this;
            $.getScript("/swipe.js", function() {
                _this.swipe(options);
            });
            return _this;
        }
        this.each(function() {
            var nav = $(this).children("p").children("a");
            var swipe = Swipe($(this)[0], {
                callback: function(index, element) {
                    $(element).parent("div").parent("div").children("p").children("a:nth-child(" + (index + 1) + ")").click();
                },
                continuous: false
            });
            nav.click(function() {
                if (options != undefined && options.selected != undefined) {
                    nav.removeClass(options.selected);
                    $(this).addClass(options.selected);
                }
                var index = parseInt($(this).attr("href").replace("#", "")) - 1;
                swipe.slide(index);
                return false;
            });
            if (nav.length > 0) {
                nav.get(0).click();
            }
        });
        return this;
    };
    
    $.fn.audio = function() {
        var height = this.height();
        if (height == 16 || height > 39) {
            this.height(39);
        }
        return this;
    };
})(jQuery);