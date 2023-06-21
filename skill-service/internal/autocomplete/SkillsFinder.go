package autocomplete

// SkillFinder defines the behavior of a skill suggestion mechanism.
// It provides an abstraction over different possible implementations for skill suggestion.
// Any type that provides a Suggest method with the specified parameters and return types
// can be said to implement the SkillFinder interface.
//
// The Suggest method takes a string prefix and returns a slice of strings.
// The expected behavior is that it returns suggestions (as strings) based on the provided prefix.
type SkillFinder interface {
	Suggest(prefix string) []string
}
