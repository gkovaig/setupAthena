#' Run Full Setup
#' @description
#' This function runs the entire process of dropping the target schema if it exists and populating the vocabulary tables.
#' @import secretary
#' @import pg13
#' @export


runSetup <-
        function(conn = conn,
                 targetSchema = "public",
                 cascade = TRUE,
                 vocabularyPath,
                 cpt4 = TRUE,
                 verbose = TRUE) {


                secretary::typewrite_note("This process will take approx 30 to 45 minutes.")
                secretary::press_enter()


                if (tolower(targetSchema) %in% tolower(pg13::lsSchema(conn = conn))) {


                                # Dropping and creating new schema
                                if (verbose) {
                                        secretary::typewrite("Dropping and creating new ", crayon::italic(targetSchema), " schema...")
                                }

                                clearSchema(conn = conn,
                                                         targetSchema = targetSchema,
                                                         cascade = TRUE)

                } else {

                        if (verbose) {
                                secretary::typewrite("Creating new ", crayon::italic(targetSchema), " schema...")
                        }

                        pg13::createSchema(conn = conn,
                                           schema = targetSchema)

                }



                if (verbose) {
                        secretary::typewrite("Executing DDL...")
                }

                ddl(conn = conn,
                    targetSchema = targetSchema)


                if (verbose) {
                        secretary::typewrite("Copying vocabularies (approx 5 minutes)...", "\n")
                }

                copyVocabularies(vocabularyPath = "~/Desktop/athena",
                                 targetSchema = targetSchema,
                                 conn = conn)

                if (verbose) {

                        secretary::typewrite("Logging Row Counts", "\n")

                }

                logRowCount(conn = conn,
                            targetSchema = targetSchema)


                if (verbose) {
                        secretary::typewrite("Executing indexes (approx 20 minutes)...", "\n")
                }


                indices(conn = conn,
                        targetSchema = targetSchema)


                if (verbose) {
                        secretary::typewrite("Executing constraints (approx 5 minutes)", "\n")
                }

                constraints(conn = conn,
                            targetSchema = targetSchema)


        }