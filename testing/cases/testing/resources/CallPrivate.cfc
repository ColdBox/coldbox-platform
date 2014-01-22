component {
    public function callit() {
        return callPrivate();
    }
    private function callPrivate() {
        return "called";
    }
}