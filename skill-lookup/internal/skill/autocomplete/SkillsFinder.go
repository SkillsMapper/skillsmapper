package autocomplete

type SkillFinder interface {
	Suggest(prefix string) []string
}
