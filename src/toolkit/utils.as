namespace _IO {
    namespace Directory {
        bool IsDirectory(const string &in path) {
            return path.EndsWith("/") || path.EndsWith("\\");
        }
    }
}
