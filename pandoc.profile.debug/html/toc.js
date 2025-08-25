// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded affix "><a href="preface.html">Preface</a></li><li class="chapter-item expanded affix "><li class="spacer"></li><li class="chapter-item expanded "><a href="languages.html"><strong aria-hidden="true">1.</strong> Languages</a></li><li class="chapter-item expanded "><a href="propLogic.html"><strong aria-hidden="true">2.</strong> Propositional Logic</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L02_propLogic/formal/syntax.lean.html"><strong aria-hidden="true">2.1.</strong> Syntax</a></li><li class="chapter-item expanded "><a href="DMT1/Library/propLogic/syntax.lean.html"><strong aria-hidden="true">2.2.</strong> Bare Code</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L02_propLogic/formal/axioms.lean.html"><strong aria-hidden="true">2.3.</strong> Examples</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L02_propLogic/formal/semantics.lean.html"><strong aria-hidden="true">2.4.</strong> Semantics</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L02_propLogic/formal/interpretation.lean.html"><strong aria-hidden="true">2.5.</strong> Interpretations</a></li></ol></li><li class="chapter-item expanded "><a href="modelTheory.html"><strong aria-hidden="true">3.</strong> Model Theory</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L03_modelTheory/models.lean.html"><strong aria-hidden="true">3.1.</strong> Models</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L03_modelTheory/truthTable.lean.html"><strong aria-hidden="true">3.2.</strong> Truth Tables</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L03_modelTheory/counterexamples.lean.html"><strong aria-hidden="true">3.3.</strong> Counterexamples</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L03_modelTheory/properties.lean.html"><strong aria-hidden="true">3.4.</strong> Propertiesx</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L03_modelTheory/validity.lean.html"><strong aria-hidden="true">3.5.</strong> Validity</a></li></ol></li><li class="chapter-item expanded "><a href="arithmetic.html"><strong aria-hidden="true">4.</strong> Arithmetic</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L04_natArithmetic/domain.lean.html"><strong aria-hidden="true">4.1.</strong> Domain</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L04_natArithmetic/syntax.lean.html"><strong aria-hidden="true">4.2.</strong> Syntax</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L04_natArithmetic/semantics.lean.html"><strong aria-hidden="true">4.3.</strong> Semantics</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L04_natArithmetic/induction.lean.html"><strong aria-hidden="true">4.4.</strong> Induction</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L04_natArithmetic/examples.lean.html"><strong aria-hidden="true">4.5.</strong> Examples</a></li></ol></li><li class="chapter-item expanded "><a href="TheoryExtensions.html"><strong aria-hidden="true">5.</strong> Theory Extensions</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L05_theoryExtensions/domain.lean.html"><strong aria-hidden="true">5.1.</strong> Domain</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L05_theoryExtensions/syntax.lean.html"><strong aria-hidden="true">5.2.</strong> Syntax</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L05_theoryExtensions/semantics.lean.html"><strong aria-hidden="true">5.3.</strong> Semantics</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L05_theoryExtensions/examples.lean.html"><strong aria-hidden="true">5.4.</strong> Examples</a></li><li class="chapter-item expanded "><a href="smt.html"><strong aria-hidden="true">5.5.</strong> Satisfiability Modulo Theories</a></li></ol></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L06_induction/induction.lean.html"><strong aria-hidden="true">6.</strong> Induction</a></li><li class="chapter-item expanded "><a href="mathlib.html"><strong aria-hidden="true">7.</strong> Mathlib</a></li><li class="chapter-item expanded "><a href="predLogic.html"><strong aria-hidden="true">8.</strong> (Higher-Order) Predicate Logic</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L07_predicateLogic/00_introduction.lean.html"><strong aria-hidden="true">8.1.</strong> Introduction</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L07_predicateLogic/01_propsAsCompTypes.lean.html"><strong aria-hidden="true">8.2.</strong> Propositions as Data Types</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L07_predicateLogic/01_propsAsLogicalTypes.lean.html"><strong aria-hidden="true">8.3.</strong> Propositions as Logical Types</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L07_predicateLogic/03_classicalReasoning.lean.html"><strong aria-hidden="true">8.4.</strong> Classical Reasoning</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L07_predicateLogic/04_predicates.lean.html"><strong aria-hidden="true">8.5.</strong> Predicates</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L07_predicateLogic/05_quantifiers.lean.html"><strong aria-hidden="true">8.6.</strong> Quantifiers</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L07_predicateLogic/05_quantifiers_all.lean.html"><strong aria-hidden="true">8.6.1.</strong> For All</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L07_predicateLogic/05_quantifiers_exists.lean.html"><strong aria-hidden="true">8.6.2.</strong> Exists</a></li></ol></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L07_predicateLogic/06_dependentTypes.lean.html"><strong aria-hidden="true">8.7.</strong> Dependent Type Theory</a></li></ol></li><li class="chapter-item expanded "><a href="setTheory.html"><strong aria-hidden="true">9.</strong> Sets and Relations</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L08_setsRelationsFunctions/C01_sets.lean.html"><strong aria-hidden="true">9.1.</strong> Sets</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L08_setsRelationsFunctions/C02_relations.lean.html"><strong aria-hidden="true">9.2.</strong> Relations</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L08_setsRelationsFunctions/C03_equality.lean.html"><strong aria-hidden="true">9.3.</strong> Equality</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L08_setsRelationsFunctions/C04_propertiesOfRelations.lean.html"><strong aria-hidden="true">9.4.</strong> Properties</a></li></ol></li><li class="chapter-item expanded "><a href="mathStructures.html"><strong aria-hidden="true">10.</strong> Abstract Algebra</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L09_algebra/C01_groups.lean.html"><strong aria-hidden="true">10.1.</strong> Groups</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L09_algebra/C02_groupActions.lean.html"><strong aria-hidden="true">10.2.</strong> Actions</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L09_algebra/C03_torsors.lean.html"><strong aria-hidden="true">10.3.</strong> Torsors over Groups</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L09_algebra/C04_vectorSpaces.lean.html"><strong aria-hidden="true">10.4.</strong> Modules and Vector Spaces</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L09_algebra/C05_affineSpaces.lean.html"><strong aria-hidden="true">10.5.</strong> Affine Spaces</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L09_algebra/C06_finiteDimensional.lean.html"><strong aria-hidden="true">10.6.</strong> n-Dimensional Spaces</a></li></ol></li><li class="chapter-item expanded "><div><strong aria-hidden="true">11.</strong> Library</div></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L10_algebra/scalar/scalar.lean.html"><strong aria-hidden="true">11.1.</strong> Scalar</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L10_algebra/tuple/tuple.lean.html"><strong aria-hidden="true">11.2.</strong> Tuple</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L10_algebra/vector/vector.lean.html"><strong aria-hidden="true">11.3.</strong> Vector</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L10_algebra/point/point.lean.html"><strong aria-hidden="true">11.4.</strong> Point</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L10_algebra/torsor/torsor.lean.html"><strong aria-hidden="true">11.5.</strong> Torsor</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L10_algebra/affine/affine.lean.html"><strong aria-hidden="true">11.6.</strong> Affine</a></li></ol></li><li class="chapter-item expanded "><a href="hetero.html"><strong aria-hidden="true">12.</strong> Type Heterogeneity</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="DMT1/Lectures/L11_TypeHeterogeneity/C00_heteroIntro.lean.html"><strong aria-hidden="true">12.1.</strong> Heterogeneous Collections</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L11_TypeHeterogeneity/C01_dynType.lean.html"><strong aria-hidden="true">12.2.</strong> Custom Dynamic Types</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L11_TypeHeterogeneity/C02_existsWrapper.lean.html"><strong aria-hidden="true">12.3.</strong> Existential Wrappers</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L11_TypeHeterogeneity/C03_heteroSig.lean.html"><strong aria-hidden="true">12.4.</strong> Heterogeneous Signatures</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L11_TypeHeterogeneity/C04_heteroList.lean.html"><strong aria-hidden="true">12.5.</strong> Heterogeneous Lists</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L11_TypeHeterogeneity/C05_heteroVector.lean.html"><strong aria-hidden="true">12.6.</strong> Heterogeneous Vectors</a></li><li class="chapter-item expanded "><a href="DMT1/Lectures/L11_TypeHeterogeneity/C06_sigmaChain.lean.html"><strong aria-hidden="true">12.7.</strong> Sigma Chains</a></li></ol></li><li class="chapter-item expanded "><li class="spacer"></li><li class="chapter-item expanded affix "><a href="build.html">Set Up for This Course</a></li><li class="chapter-item expanded affix "><a href="resources.html">Learning Resources</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0].split("?")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
